//
//  OfflineQuestionProvider.swift
//  OhLuckyQuiz
//

import Foundation

struct OfflineQuestionProvider {

    /// Совпадает с amount в QuestionNetworkService — столько вопросов идёт в одну партию
    static let batchSize = 5

    private static var cachedBanks: [AppLanguage: [MultipleQuestion]] = [:]

    static func loadQuestions(category: QuizCategory, difficulty: Difficulty) -> [MultipleQuestion] {
        let pool = bank().filter { $0.difficulty == difficulty && $0.category == category.rawValue }
        return Array(pool.shuffled().prefix(batchSize))
    }

    /// Банк читается с диска один раз на язык, а не заново на каждую из трёх партий
    private static func bank() -> [MultipleQuestion] {
        let language = AppLanguage.current
        if let cached = cachedBanks[language] { return cached }

        guard let url = Bundle.main.url(forResource: "offline_questions_\(language.rawValue)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let questions = (try? decoder.decode(NetworkModel.self, from: data))?.responseResult ?? []
        cachedBanks[language] = questions
        return questions
    }
}
