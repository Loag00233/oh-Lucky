//
//  Question.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

struct MultipleQuestion: Decodable {

    let question: String?
    let correctAnswer: String?
    let incorrectAnswers: [String]?
    let difficulty: Difficulty?

    enum CodingKeys: String, CodingKey {
        case question, correctAnswer, incorrectAnswers, difficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decodeIfPresent(String.self, forKey: .question).map { $0.removingPercentEncoding ?? $0 }
        correctAnswer = try container.decodeIfPresent(String.self, forKey: .correctAnswer).map { $0.removingPercentEncoding ?? $0 }
        incorrectAnswers = try container.decodeIfPresent([String].self, forKey: .incorrectAnswers)?.map { $0.removingPercentEncoding ?? $0 }
        difficulty = try container.decodeIfPresent(Difficulty.self, forKey: .difficulty)
    }
}

enum Difficulty: String, Decodable {
    case easy, medium, hard
}
