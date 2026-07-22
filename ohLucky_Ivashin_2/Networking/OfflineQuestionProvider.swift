//
//  OfflineQuestionProvider.swift
//  ohLucky_Ivashin_2
//

import Foundation

struct OfflineQuestionProvider {
    static func loadQuestions(difficulty: Difficulty) -> [MultipleQuestion] {
        guard let url = Bundle.main.url(forResource: "offline_questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let networkModel = try? decoder.decode(NetworkModel.self, from: data) else {
            return []
        }

        return networkModel.responseResult.filter { $0.difficulty == difficulty }
    }
}
