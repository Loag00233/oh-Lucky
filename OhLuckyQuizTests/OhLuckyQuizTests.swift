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

        @Test("Правильный ответ кладёт в банк сумму текущего вопроса")
        func correctAnswerBanksPrize() throws {
            let game = try makeGame()

            game.registerAnswer(correctAnswer)
            #expect(game.bankedAmount == 100)
            #expect(game.correctAnswersCount == 1)

            game.goToNext()
            game.registerAnswer(correctAnswer)
            #expect(game.bankedAmount == 300)
            #expect(game.correctAnswersCount == 2)
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

        @Test("Записанные результаты читаются обратно")
        func recordsSurviveRoundTrip() {
            let snapshot = StatsSnapshot()
            defer { snapshot.restore() }

            StatsStore.recordGameStarted()
            StatsStore.recordAnswer(category: .history, difficulty: .medium, isCorrect: true)
            StatsStore.recordAnswer(category: .history, difficulty: .medium, isCorrect: false)
            StatsStore.recordGameFinished(earnedAmount: 1_000)
            StatsStore.recordGameFinished(earnedAmount: 32_000)

            let stats = StatsStore.load()
            #expect(stats.gamesPlayed == 1)
            #expect(stats.totalEarned == 33_000)
            #expect(stats.bestWin == 32_000)

            let record = stats.records[StatsStore.key(category: .history, difficulty: .medium)]
            #expect(record?.total == 2)
            #expect(record?.correct == 1)
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
    func fetchBatch(category: QuizCategory, difficulty: Difficulty, isMultiple: Bool) async throws -> [MultipleQuestion] {
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
