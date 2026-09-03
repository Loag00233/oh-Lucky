//
//  Achievement.swift
//  OhLuckyQuiz
//

import Foundation

/// Достижение — чистая функция от `QuizStats`, а не отдельно хранимый флаг: тогда оно
/// засчитывается ретроактивно, не расходится с цифрами статистики и проверяется тестом
/// без запуска игры. Хранить отдельно приходится только то, что уже показали игроку.
enum Achievement: String, CaseIterable {

    // путь
    case firstGame, tenGames, fiftyGames
    // мастерство
    case firstSafetyNet, secondSafetyNet, million, cleanMillion, doubleMillion
    // широта
    case allCategories, sharpCategory, broadAccuracy
    // курьёзы
    case timeoutLoss, firstQuestionLoss

    /// SF Symbol: ничего не весит, масштабируется вместе со шрифтом и не требует перевода.
    var icon: String {
        switch self {
        case .firstGame: return "flag.fill"
        case .tenGames: return "repeat"
        case .fiftyGames: return "crown.fill"
        case .firstSafetyNet: return "shield.fill"
        case .secondSafetyNet: return "shield.lefthalf.filled"
        case .million: return "trophy.fill"
        case .cleanMillion: return "sparkles"
        case .doubleMillion: return "trophy.circle.fill"
        case .allCategories: return "books.vertical.fill"
        case .sharpCategory: return "target"
        case .broadAccuracy: return "chart.bar.fill"
        case .timeoutLoss: return "hourglass"
        case .firstQuestionLoss: return "xmark.octagon.fill"
        }
    }

    /// Ключи — строковыми литералами: интерполяция дала бы динамический ключ, которого нет в каталоге.
    var title: String {
        switch self {
        case .firstGame: return localized("First round")
        case .tenGames: return localized("Regular")
        case .fiftyGames: return localized("Veteran")
        case .firstSafetyNet: return localized("Safety net")
        case .secondSafetyNet: return localized("Halfway there")
        case .million: return localized("Millionaire")
        case .cleanMillion: return localized("No help needed")
        case .doubleMillion: return localized("Twice lucky")
        case .allCategories: return localized("Polymath")
        case .sharpCategory: return localized("Specialist")
        case .broadAccuracy: return localized("Well-rounded")
        case .timeoutLoss: return localized("Out of time")
        case .firstQuestionLoss: return localized("Off the rails")
        }
    }

    var details: String {
        switch self {
        case .firstGame: return localized("Play your first game")
        case .tenGames: return localized("Play 10 games")
        case .fiftyGames: return localized("Play 50 games")
        case .firstSafetyNet: return localized("Answer 5 questions in one game")
        case .secondSafetyNet: return localized("Answer 10 questions in one game")
        case .million: return localized("Take the top prize")
        case .cleanMillion: return localized("Take the top prize without using 50/50")
        case .doubleMillion: return localized("Take the top prize twice")
        case .allCategories: return localized("Play a game in every category")
        case .sharpCategory: return localized("80% correct in a category with 20 answers or more")
        case .broadAccuracy: return localized("70% correct in all categories, 10+ answers each")
        case .timeoutLoss: return localized("Lose a game to the timer")
        case .firstQuestionLoss: return localized("Lose on the very first question")
        }
    }

    /// Текущий прогресс и порог. Заблокированные показываем с ним же: экран из тринадцати
    /// замков без единой цифры новичка не возвращает.
    func progress(in stats: QuizStats) -> (current: Int, goal: Int) {
        switch self {
        case .firstGame: return (min(stats.gamesPlayed, 1), 1)
        case .tenGames: return (min(stats.gamesPlayed, 10), 10)
        case .fiftyGames: return (min(stats.gamesPlayed, 50), 50)
        case .firstSafetyNet: return (min(stats.bestStreak, 5), 5)
        case .secondSafetyNet: return (min(stats.bestStreak, 10), 10)
        case .million: return (min(stats.millionsWon, 1), 1)
        case .cleanMillion: return (min(stats.cleanMillions, 1), 1)
        case .doubleMillion: return (min(stats.millionsWon, 2), 2)

        case .allCategories:
            let played = QuizCategory.allCases.filter { stats.answeredCount(for: $0) > 0 }
            return (played.count, QuizCategory.allCases.count)

        case .sharpCategory:
            let sharp = QuizCategory.allCases.contains {
                stats.answeredCount(for: $0) >= 20 && stats.accuracyPercent(for: $0) >= 80
            }
            return (sharp ? 1 : 0, 1)

        case .broadAccuracy:
            let good = QuizCategory.allCases.filter {
                stats.answeredCount(for: $0) >= 10 && stats.accuracyPercent(for: $0) >= 70
            }
            return (good.count, QuizCategory.allCases.count)

        case .timeoutLoss: return (min(stats.timeoutLosses, 1), 1)
        case .firstQuestionLoss: return (min(stats.firstQuestionLosses, 1), 1)
        }
    }

    func isUnlocked(in stats: QuizStats) -> Bool {
        let p = progress(in: stats)
        return p.current >= p.goal
    }
}

/// Хранит только то, что уже показали: сами достижения каждый раз пересчитываются из статистики.
enum AchievementsStore {

    private static let defaultsKey = "shownAchievements"

    static func shown() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: defaultsKey) ?? [])
    }

    /// Открытые, но ещё не показанные — и сразу помечает их показанными, чтобы тост
    /// не повторялся на каждом следующем экране результата.
    static func consumeNewlyUnlocked(in stats: QuizStats) -> [Achievement] {
        let alreadyShown = shown()
        let fresh = Achievement.allCases.filter { $0.isUnlocked(in: stats) && !alreadyShown.contains($0.rawValue) }
        guard !fresh.isEmpty else { return [] }

        UserDefaults.standard.set(Array(alreadyShown) + fresh.map(\.rawValue), forKey: defaultsKey)
        return fresh
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
}
