//
//  QuizStats.swift
//  ohLucky_Ivashin_2
//

import Foundation

struct QuizStats: Codable {
    struct Record: Codable {
        var correct = 0
        var total = 0
    }
    var gamesPlayed = 0
    var records: [String: Record] = [:] // ключ — StatsStore.key(category:difficulty:)
}

extension QuizStats {
    var totalAnswered: Int { records.values.reduce(0) { $0 + $1.total } }
    var totalCorrect: Int { records.values.reduce(0) { $0 + $1.correct } }

    var overallAccuracyPercent: Int {
        percent(correct: totalCorrect, total: totalAnswered)
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

    static func recordAnswer(category: QuizCategory, difficulty: Difficulty, isCorrect: Bool) {
        var stats = load()
        let k = key(category: category, difficulty: difficulty)
        var record = stats.records[k] ?? QuizStats.Record()
        record.total += 1
        if isCorrect { record.correct += 1 }
        stats.records[k] = record
        save(stats)
    }
}
