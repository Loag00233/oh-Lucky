//
//  OhLuckyQuizTests.swift
//  OhLuckyQuizTests
//
//  Created by Work on 25.08.2026.
//

import Testing
import UIKit
@testable import OhLuckyQuiz

/// Всё внутри сериализовано: язык приложения, кэш банков и статистика — глобальное состояние,
/// параллельный прогон растащил бы его между тестами.
@Suite("OhLuckyQuiz", .serialized)
struct OhLuckyQuizTests {

    // MARK: - Офлайн-банк

    @Suite("Офлайн-банк вопросов")
    struct OfflineBank {

        /// Пустая корзина «категория × сложность» — это зависший спиннер в игре:
        /// провайдер вернёт пустой массив, getQuestions() выйдет по guard и экран останется в загрузке.
        @Test("Каждая корзина отдаёт полную партию вопросов",
              arguments: AppLanguage.allCases, QuizCategory.allCases)
        func bucketDeliversFullBatch(language: AppLanguage, category: QuizCategory) {
            let snapshot = LanguageSnapshot()
            defer { snapshot.restore() }
            AppLanguage.select(language)

            for difficulty in Difficulty.all {
                let questions = OfflineQuestionProvider.loadQuestions(category: category, difficulty: difficulty)

                #expect(questions.count == OfflineQuestionProvider.batchSize,
                        "\(language.rawValue): \(category)/\(difficulty.rawValue) — партия оборвётся")

                for question in questions {
                    #expect(question.question?.isEmpty == false)
                    #expect(question.correctAnswer?.isEmpty == false)
                    #expect(question.incorrectAnswers?.count == 3)
                    #expect(question.difficulty == difficulty)
                    #expect(question.category == category.rawValue)

                    let options = (question.incorrectAnswers ?? []) + [question.correctAnswer ?? ""]
                    #expect(Set(options).count == options.count,
                            "\(language.rawValue): повторяющиеся варианты ответа")
                }
            }
        }
    }

    // MARK: - Игра

    @Suite("Игра")
    struct Game {

        @Test("Сумма вопроса идёт по лестнице призов")
        func prizeLadder() throws {
            let game = try makeGame()

            #expect(game.currentQuestionSum == 100)
            game.currentQuestionIndex = 4
            #expect(game.currentQuestionSum == 1_000)
            game.currentQuestionIndex = 9
            #expect(game.currentQuestionSum == 32_000)
            game.currentQuestionIndex = 14
            #expect(game.currentQuestionSum == 1_000_000)
        }

        @Test("Правильный ответ поднимает банк до ступени текущего вопроса")
        func correctAnswerBanksPrize() throws {
            let game = try makeGame()

            game.registerAnswer(correctAnswer)
            #expect(game.bankedAmount == 100)

            game.goToNext()
            game.registerAnswer(correctAnswer)
            #expect(game.bankedAmount == 200)
        }

        @Test("Правильный ответ увеличивает счётчик верных")
        func correctAnswerIncrementsCount() throws {
            let game = try makeGame()

            game.registerAnswer(correctAnswer)
            #expect(game.correctAnswersCount == 1)
        }

        /// Банк — последняя взятая ступень. Пока он был копилкой, за партию набегало 2 003 100.
        @Test("Пятнадцать правильных ответов дают ровно миллион")
        func fullGameBanksMillion() throws {
            let game = try makeGame()

            for _ in 0..<(game.totalQuestionsCount - 1) {
                game.registerAnswer(correctAnswer)
                game.goToNext()
            }
            game.registerAnswer(correctAnswer)

            #expect(game.bankedAmount == 1_000_000)
        }

        /// Досрочный выход отдаёт банк, проигрыш — несгораемую. Суммы обязаны расходиться.
        @Test("После семи верных ответов банк 4 000, а несгораемая 1 000")
        func bankAndSafetyNetDiverge() throws {
            let game = try makeGame()

            for _ in 0..<7 {
                game.registerAnswer(correctAnswer)
                game.goToNext()
            }

            #expect(game.bankedAmount == 4_000)
            #expect(game.safetyNetAmount == 1_000)
        }

        @Test("Неправильный ответ не трогает банк")
        func wrongAnswerKeepsBank() throws {
            let game = try makeGame()

            game.registerAnswer("Неверно 1")
            #expect(game.bankedAmount == 0)
            #expect(game.correctAnswersCount == 0)
        }

        @Test("Несгораемая сумма зависит от числа правильных ответов",
              arguments: [(4, 0), (5, 1_000), (9, 1_000), (10, 32_000), (15, 32_000)])
        func safetyNet(correctAnswers: Int, expected: Int) throws {
            let game = try makeGame()
            game.correctAnswersCount = correctAnswers

            #expect(game.safetyNetAmount == expected)
        }

        @Test("Варианты перемешаны, правильный среди них")
        func answersContainCorrectOne() throws {
            let game = try makeGame()
            game.prepareAnswers()

            #expect(game.currentAnswers.count == 4)
            #expect(game.currentAnswers.contains(correctAnswer))
            #expect(Set(game.currentAnswers).count == 4)
        }

        @Test("Последний вопрос — пятнадцатый")
        func lastQuestionIsFifteenth() throws {
            let game = try makeGame()

            game.currentQuestionIndex = 13
            #expect(game.isLastQuestion == false)
            game.currentQuestionIndex = 14
            #expect(game.isLastQuestion)
        }

        // MARK: Подсказка 50/50

        @Test("Подсказка убирает ровно два варианта")
        func hintRemovesTwoAnswers() throws {
            let game = try makeGame()
            game.prepareAnswers()

            #expect(game.useHint().count == 2)
        }

        @Test("Правильный ответ подсказкой не убирается")
        func hintKeepsCorrectAnswer() throws {
            let game = try makeGame()
            game.prepareAnswers()

            #expect(game.useHint().contains(correctAnswer) == false)
        }

        @Test("После использования подсказка недоступна")
        func hintIsSpentAfterUse() throws {
            let game = try makeGame()
            game.prepareAnswers()

            _ = game.useHint()

            #expect(game.isHintAvailable == false)
        }

        @Test("Повторная подсказка ничего не убирает")
        func secondHintRemovesNothing() throws {
            let game = try makeGame()
            game.prepareAnswers()

            _ = game.useHint()

            #expect(game.useHint().isEmpty)
        }

        // MARK: Таймер
        //
        // Время считается от даты дедлайна, а не тиками: приложение сворачивают, и `Timer` в фоне
        // не идёт. Поэтому всё проверяется подстановкой `now`, без run loop.

        @Test("Сразу после старта на таймере полные двадцать секунд")
        func timerStartsFull() throws {
            let game = try makeGame()
            let now = Date()

            game.startTimer(now: now)

            #expect(game.remainingSeconds(now: now) == 20)
        }

        @Test("Без запущенного таймера остаток нулевой")
        func timerIsZeroBeforeStart() throws {
            let game = try makeGame()

            #expect(game.remainingSeconds() == 0)
        }

        @Test("К моменту дедлайна остаток обнуляется")
        func timerEmptyAtDeadline() throws {
            let game = try makeGame()
            let now = Date()

            game.startTimer(now: now)

            #expect(game.remainingSeconds(now: now.addingTimeInterval(20)) == 0)
        }

        @Test("Просроченный дедлайн не уводит остаток в минус")
        func timerNeverGoesNegative() throws {
            let game = try makeGame()
            let now = Date()

            game.startTimer(now: now)

            #expect(game.remainingSeconds(now: now.addingTimeInterval(100)) == 0)
        }

        @Test("Истёкшее время распознаётся только после дедлайна")
        func timeIsUpOnlyAfterDeadline() throws {
            let game = try makeGame()
            let now = Date()

            game.startTimer(now: now)

            #expect(game.isTimeUp(now: now.addingTimeInterval(19)) == false)
        }

        @Test("Потраченное время — это разница между двадцатью секундами и остатком")
        func elapsedGrowsWithTime() throws {
            let game = try makeGame()
            let now = Date()

            game.startTimer(now: now)

            #expect(game.elapsedSeconds(now: now.addingTimeInterval(7)) == 7)
        }

        @Test("Остановленный таймер время не копит")
        func stoppedTimerHasNoElapsed() throws {
            let game = try makeGame()

            game.startTimer()
            game.stopTimer()

            #expect(game.elapsedSeconds() == 0)
        }
    }

    // MARK: - Статистика

    @Suite("Статистика")
    struct Stats {

        @Test("Общая точность считается по всем записям и округляется")
        func overallAccuracy() {
            var stats = QuizStats()
            stats.records = [
                StatsStore.key(category: .film, difficulty: .easy): .init(correct: 2, total: 3)
            ]

            #expect(stats.overallAccuracyPercent == 67)
        }

        @Test("Точность по категории складывает три сложности")
        func categoryAccuracy() {
            var stats = QuizStats()
            stats.records = [
                StatsStore.key(category: .music, difficulty: .easy): .init(correct: 3, total: 4),
                StatsStore.key(category: .music, difficulty: .hard): .init(correct: 1, total: 4),
                StatsStore.key(category: .film, difficulty: .easy): .init(correct: 0, total: 10)
            ]

            #expect(stats.accuracyPercent(for: .music) == 50)
        }

        @Test("Без сыгранных игр средний выигрыш равен нулю, а не делится на ноль")
        func averageWinWithoutGames() {
            #expect(QuizStats().averageWinPerGame == 0)
        }

        @Test("Без учтённых ответов среднее время равно нулю, а не делится на ноль")
        func averageAnswerTimeWithoutAnswers() {
            #expect(QuizStats().averageAnswerSeconds == 0)
        }

        /// Синтезированный init(from:) значения по умолчанию не использует и на пропущенном ключе
        /// падает, а load() глушит ошибку через try? — то есть новое поле стёрло бы всю статистику.
        @Test("Сохранённая статистика без новых ключей читается, а не обнуляется")
        func decodesPayloadWithoutNewKeys() throws {
            let legacy = #"{"gamesPlayed":7,"records":{},"totalEarned":5000,"bestWin":5000}"#

            let stats = try JSONDecoder().decode(QuizStats.self, from: Data(legacy.utf8))

            #expect(stats.gamesPlayed == 7)
        }

        @Test("Отсутствующее в данных поле читается нулём")
        func missingFieldDecodesAsZero() throws {
            let legacy = #"{"gamesPlayed":7,"records":{},"totalEarned":5000,"bestWin":5000}"#

            let stats = try JSONDecoder().decode(QuizStats.self, from: Data(legacy.utf8))

            #expect(stats.bestStreak == 0)
        }

        @Test("Лучшая серия берёт максимум по партиям, а не последнюю")
        func bestStreakKeepsMaximum() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameFinished(earnedAmount: 1_000, correctAnswers: 7, outcome: .lost)
            StatsStore.recordGameFinished(earnedAmount: 0, correctAnswers: 2, outcome: .lost)

            #expect(StatsStore.load().bestStreak == 7)
        }

        @Test("Миллион без подсказки попадает в чистые")
        func cleanMillionCounted() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameFinished(earnedAmount: 1_000_000, correctAnswers: 15, outcome: .won)

            #expect(StatsStore.load().cleanMillions == 1)
        }

        @Test("Миллион с подсказкой в чистые не идёт")
        func hintedMillionIsNotClean() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameFinished(earnedAmount: 1_000_000, correctAnswers: 15, outcome: .won, usedHint: true)

            #expect(StatsStore.load().cleanMillions == 0)
        }

        /// Выход с деньгами на первом вопросе — не проигрыш, ачивка «проиграл на первом» не должна открыться.
        @Test("Досрочный выход не считается проигрышем на первом вопросе")
        func quitIsNotFirstQuestionLoss() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameFinished(earnedAmount: 0, correctAnswers: 0, outcome: .quit)

            #expect(StatsStore.load().firstQuestionLosses == 0)
        }

        @Test("Проигрыш на первом вопросе засчитывается")
        func firstQuestionLossCounted() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameFinished(earnedAmount: 0, correctAnswers: 0, outcome: .lost)

            #expect(StatsStore.load().firstQuestionLosses == 1)
        }

        @Test("Сброс очищает накопленную статистику")
        func resetClearsStats() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameStarted()
            StatsStore.reset()

            #expect(StatsStore.load().gamesPlayed == 0)
        }

        @Test("Среднее время ответа делит накопленные секунды на число ответов")
        func averageAnswerTimeIsAveraged() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordAnswer(category: .history, difficulty: .easy, isCorrect: true, seconds: 4)
            StatsStore.recordAnswer(category: .history, difficulty: .easy, isCorrect: true, seconds: 8)

            #expect(StatsStore.load().averageAnswerSeconds == 6)
        }

        @Test("Записанные результаты читаются обратно")
        func recordsSurviveRoundTrip() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameStarted()
            StatsStore.recordAnswer(category: .history, difficulty: .medium, isCorrect: true, seconds: 4)
            StatsStore.recordAnswer(category: .history, difficulty: .medium, isCorrect: false, seconds: 8)
            StatsStore.recordGameFinished(earnedAmount: 1_000, correctAnswers: 5, outcome: .lost)
            StatsStore.recordGameFinished(earnedAmount: 32_000, correctAnswers: 10, outcome: .lost)

            let stats = StatsStore.load()
            #expect(stats.gamesPlayed == 1)
            #expect(stats.totalEarned == 33_000)
            #expect(stats.bestWin == 32_000)

            let record = stats.records[StatsStore.key(category: .history, difficulty: .medium)]
            #expect(record?.total == 2)
            #expect(record?.correct == 1)
        }
    }

    // MARK: - Достижения

    @Suite("Достижения")
    struct Achievements {

        @Test("До порога достижение закрыто")
        func lockedBelowThreshold() {
            var stats = QuizStats()
            stats.gamesPlayed = 9

            #expect(Achievement.tenGames.isUnlocked(in: stats) == false)
        }

        @Test("Ровно на пороге достижение открывается")
        func unlocksExactlyAtThreshold() {
            var stats = QuizStats()
            stats.gamesPlayed = 10

            #expect(Achievement.tenGames.isUnlocked(in: stats))
        }

        @Test("Миллион с подсказкой чистым не считается")
        func cleanMillionNeedsCleanRun() {
            var stats = QuizStats()
            stats.millionsWon = 1

            #expect(Achievement.cleanMillion.isUnlocked(in: stats) == false)
        }

        @Test("Десять категорий из одиннадцати достижение не открывают")
        func allCategoriesNeedsEveryCategory() {
            var stats = QuizStats()
            for category in QuizCategory.allCases.dropLast() {
                stats.records[StatsStore.key(category: category, difficulty: .easy)] = QuizStats.Record(correct: 1, total: 1)
            }

            #expect(Achievement.allCategories.isUnlocked(in: stats) == false)
        }

        @Test("Точность в категории засчитывается только при двадцати ответах")
        func sharpCategoryNeedsEnoughAnswers() {
            var stats = QuizStats()
            stats.records[StatsStore.key(category: .history, difficulty: .easy)] = QuizStats.Record(correct: 19, total: 19)

            #expect(Achievement.sharpCategory.isUnlocked(in: stats) == false)
        }

        /// Опечатка в имени символа даст пустой квадрат на экране, а не ошибку сборки.
        @Test("Иконка каждого достижения есть в SF Symbols")
        func everyIconResolves() {
            let broken = Achievement.allCases.filter { UIImage(systemName: $0.icon) == nil }

            #expect(broken.isEmpty)
        }

        @Test("Открытое достижение показывается один раз")
        func achievementIsAnnouncedOnce() {
            let snapshot = AchievementsSnapshot()
            defer { snapshot.restore() }

            var stats = QuizStats()
            stats.gamesPlayed = 1
            _ = AchievementsStore.consumeNewlyUnlocked(in: stats)

            #expect(AchievementsStore.consumeNewlyUnlocked(in: stats).isEmpty)
        }
    }

    // MARK: - Экран игры

    @Suite("Экран игры")
    struct GameScreen {

        /// Русский язык играет только из локального банка — сеть при нём не трогается вовсе.
        @Test("Вопрос из банка доезжает до экрана")
        @MainActor
        func questionReachesScreen() async throws {
            let languageSnapshot = LanguageSnapshot()
            let statsSnapshot = StatsSnapshot()
            defer {
                languageSnapshot.restore()
                statsSnapshot.restore()
            }
            AppLanguage.select(.ru)

            let controller = GameViewController(networkService: UnusedNetworkService(),
                                                category: .generalKnowledge)
            controller.loadViewIfNeeded()

            try await waitUntil { controller.answers.count == 4 }

            #expect(controller.gameView.questionTextLabel.text?.isEmpty == false)
            #expect(controller.gameView.answersTableView.numberOfRows(inSection: 0) == 4)
            #expect(controller.gameView.bankQuestionSumSubLabel.text?.isEmpty == false)
        }
    }
}

// MARK: - Хелперы

private let correctAnswer = "Верно"

private extension Difficulty {
    static let all: [Difficulty] = [.easy, .medium, .hard]
}

/// `MultipleQuestion` умеет только декодироваться, поэтому фикстура собирается тем же путём,
/// что и боевые данные — через JSON.
private func makeQuestion(text: String = "Вопрос",
                          category: QuizCategory = .generalKnowledge,
                          difficulty: Difficulty = .easy) throws -> MultipleQuestion {
    let payload: [String: Any] = [
        "question": text,
        "correct_answer": correctAnswer,
        "incorrect_answers": ["Неверно 1", "Неверно 2", "Неверно 3"],
        "difficulty": difficulty.rawValue,
        "category": category.rawValue
    ]
    let data = try JSONSerialization.data(withJSONObject: payload)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(MultipleQuestion.self, from: data)
}

private func makeGame() throws -> QuizGame {
    let game = QuizGame()
    game.gameQuestion = try (0..<game.totalQuestionsCount).map { try makeQuestion(text: "Вопрос \($0 + 1)") }
    return game
}

/// Сеть в этих тестах вызываться не должна — если вызвалась, тест обязан упасть с внятной причиной.
private struct UnusedNetworkService: QuestionNetworkServiceType {
    func fetchBatch(category: QuizCategory, difficulty: Difficulty) async throws -> [MultipleQuestion] {
        Issue.record("Сеть не должна вызываться: русский язык играет из локального банка")
        throw APIError.noResults
    }
}

@MainActor
private func waitUntil(timeout: Duration = .seconds(3), _ condition: () -> Bool) async throws {
    let deadline = ContinuousClock.now + timeout
    while ContinuousClock.now < deadline {
        if condition() { return }
        try await Task.sleep(for: .milliseconds(50))
    }
    Issue.record("Экран не заполнился за \(timeout)")
}

/// Ключи ниже продублированы строками: в `AppLanguage` и `StatsStore` они приватные.
/// Если там переименуют ключ, тесты перестанут изолировать состояние — но и продовый код
/// потеряет ранее сохранённые данные, так что расхождение вылезет сразу.
private struct LanguageSnapshot {
    private let stored: String?
    private let current: AppLanguage

    init() {
        stored = UserDefaults.standard.string(forKey: "appLanguage")
        current = AppLanguage.current
    }

    func restore() {
        AppLanguage.select(current)
        if let stored {
            UserDefaults.standard.set(stored, forKey: "appLanguage")
        } else {
            UserDefaults.standard.removeObject(forKey: "appLanguage")
        }
    }
}

private struct StatsSnapshot {
    private let stored: Data?

    init() {
        stored = UserDefaults.standard.data(forKey: "quizStats")
        UserDefaults.standard.removeObject(forKey: "quizStats")
    }

    func restore() {
        if let stored {
            UserDefaults.standard.set(stored, forKey: "quizStats")
        } else {
            UserDefaults.standard.removeObject(forKey: "quizStats")
        }
    }
}

private struct AchievementsSnapshot {
    private let stored: [String]?

    init() {
        stored = UserDefaults.standard.stringArray(forKey: "shownAchievements")
        AchievementsStore.reset()
    }

    func restore() {
        if let stored {
            UserDefaults.standard.set(stored, forKey: "shownAchievements")
        } else {
            AchievementsStore.reset()
        }
    }
}
