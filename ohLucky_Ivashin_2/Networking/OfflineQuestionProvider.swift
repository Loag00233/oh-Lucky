//
//  OfflineQuestionProvider.swift
//  ohLucky_Ivashin_2
//

import Foundation

struct OfflineQuestionProvider {
    static func loadQuestions(category: QuizCategory, difficulty: Difficulty) -> [MultipleQuestion] {
        guard let url = Bundle.main.url(forResource: "offline_questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let networkModel = try? decoder.decode(NetworkModel.self, from: data) else {
            return []
        }

        let byDifficulty = networkModel.responseResult.filter { $0.difficulty == difficulty }
        let byCategoryToo = byDifficulty.filter { $0.category == category.rawValue }
        // если для этой категории в офлайн-банке ничего нет — не оставляем игрока без вопросов
        return byCategoryToo.isEmpty ? byDifficulty : byCategoryToo
    }
}
