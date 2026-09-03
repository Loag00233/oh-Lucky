//
//  QuizStats.swift
//  OhLuckyQuiz
//

import Foundation

struct QuizStats: Codable {
    struct Record: Codable {
        var correct = 0
        var total = 0
    }
    var gamesPlayed = 0
    var records: [String: Record] = [:] // ключ — StatsStore.key(category:difficulty:)
    var totalEarned = 0
    var bestWin = 0

  
    var bestStreak = 0 // Партия кончается на первой ошибке, поэтому серия за игру это и есть число верных ответов
    var millionsWon = 0
    var cleanMillions = 0 // миллионы, взятые без подсказки
    var gamesWithHint = 0 // «игр без подсказки» = gamesPlayed - gamesWithHint, отдельное поле не нужно
    var timeoutLosses = 0
    var firstQuestionLosses = 0
    var answerSecondsTotal = 0
    var timedAnswers = 0
}

/// Синтезированный `init(from:)` значения по умолчанию не использует: пропущенный ключ кидает
/// ошибку, `load()` глушит её через `try?` и возвращает пустую структуру — то есть добавление
/// любого нового поля молча стёрло бы всю накопленную статистику. Отсюда `decodeIfPresent`.
///
/// Инициализатор живёт в расширении намеренно: объявленный в теле структуры, он отменил бы
/// синтез `init()`, которым пользуется весь остальной код.
extension QuizStats {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()

        gamesPlayed = try container.decodeIfPresent(Int.self, forKey: .gamesPlayed) ?? 0
        records = try container.decodeIfPresent([String: Record].self, forKey: .records) ?? [:]
        totalEarned = try container.decodeIfPresent(Int.self, forKey: .totalEarned) ?? 0
        bestWin = try container.decodeIfPresent(Int.self, forKey: .bestWin) ?? 0
        bestStreak = try container.decodeIfPresent(Int.self, forKey: .bestStreak) ?? 0
        millionsWon = try container.decodeIfPresent(Int.self, forKey: .millionsWon) ?? 0
        cleanMillions = try container.decodeIfPresent(Int.self, forKey: .cleanMillions) ?? 0
        gamesWithHint = try container.decodeIfPresent(Int.self, forKey: .gamesWithHint) ?? 0
        timeoutLosses = try container.decodeIfPresent(Int.self, forKey: .timeoutLosses) ?? 0
        firstQuestionLosses = try container.decodeIfPresent(Int.self, forKey: .firstQuestionLosses) ?? 0
        answerSecondsTotal = try container.decodeIfPresent(Int.self, forKey: .answerSecondsTotal) ?? 0
        timedAnswers = try container.decodeIfPresent(Int.self, forKey: .timedAnswers) ?? 0
    }
}

extension QuizStats.Record {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        correct = try container.decodeIfPresent(Int.self, forKey: .correct) ?? 0
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
    }
}

/// Чем кончилась партия. Нужен, чтобы отличать добровольный выход с деньгами от проигрыша:
/// у них разные последствия для статистики.
enum GameOutcome {
    case won      // взята последняя ступень
    case lost     // неверный ответ
    case timedOut // не успел ответить
    case quit     // забрал банк и вышел
}

extension QuizStats {
    var totalAnswered: Int { records.values.reduce(0) { $0 + $1.total } }
    var totalCorrect: Int { records.values.reduce(0) { $0 + $1.correct } }

    var overallAccuracyPercent: Int {
        percent(correct: totalCorrect, total: totalAnswered)
    }

    var averageWinPerGame: Int { gamesPlayed > 0 ? totalEarned / gamesPlayed : 0 }

    var averageAnswerSeconds: Int { timedAnswers > 0 ? answerSecondsTotal / timedAnswers : 0 }

    func answeredCount(for category: QuizCategory) -> Int {
        [Difficulty.easy, .medium, .hard]
            .compactMap { records[StatsStore.key(category: category, difficulty: $0)] }
            .reduce(0) { $0 + $1.total }
    }

    func accuracyPercent(for category: QuizCategory) -> Int {
        let recs = [Difficulty.easy, .medium, .hard]
            .compactMap { records[StatsStore.key(category: category, difficulty: $0)] }
        let total = recs.reduce(0) { $0 + $1.total }
        let correct = recs.reduce(0) { $0 + $1.correct }
        return percent(correct: correct, total: total)
    }

    private func percent(correct: Int, total: Int) -> Int {
        total > 0 ? Int((Double(correct) / Double(total) * 100).rounded()) : 0
    }
}

enum StatsStore {
    private static let defaultsKey = "quizStats"

    static func key(category: QuizCategory, difficulty: Difficulty) -> String {
        "\(category.rawValue)_\(difficulty.rawValue)"
    }

    static func load() -> QuizStats {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let stats = try? JSONDecoder().decode(QuizStats.self, from: data) else {
            return QuizStats()
        }
        return stats
    }

    private static func save(_ stats: QuizStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    static func recordGameStarted() {
        var stats = load()
        stats.gamesPlayed += 1
        save(stats)
    }

    static func recordGameFinished(earnedAmount: Int,
                                   correctAnswers: Int,
                                   outcome: GameOutcome,
                                   usedHint: Bool = false) {
        var stats = load()
        stats.totalEarned += earnedAmount
        stats.bestWin = max(stats.bestWin, earnedAmount)
        stats.bestStreak = max(stats.bestStreak, correctAnswers)

        if usedHint { stats.gamesWithHint += 1 }
        if outcome == .timedOut { stats.timeoutLosses += 1 }
        // добровольный выход на первом вопросе проигрышем не считается
        if outcome != .quit && correctAnswers == 0 { stats.firstQuestionLosses += 1 }

        if outcome == .won {
            stats.millionsWon += 1
            if !usedHint { stats.cleanMillions += 1 }
        }

        save(stats)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    static func recordAnswer(category: QuizCategory, difficulty: Difficulty, isCorrect: Bool, seconds: Int) {
        var stats = load()
        let k = key(category: category, difficulty: difficulty)
        var record = stats.records[k] ?? QuizStats.Record()
        record.total += 1
        if isCorrect { record.correct += 1 }
        stats.records[k] = record
        stats.answerSecondsTotal += seconds
        stats.timedAnswers += 1
        save(stats)
    }
}
