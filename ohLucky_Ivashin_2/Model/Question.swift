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
    
    var answers: [String] {
        guard let incorrectAnswers = incorrectAnswers else {
            return []
        }
        var ans = incorrectAnswers
        if let correctAnswer = correctAnswer {
            ans.append(correctAnswer)
        }
        return ans.shuffled()
    }
    
    enum Difficulty: String, Decodable {
        case easy
        case medium
        case hard
    }
    
}

enum Difficulty: String {
    case easy, medium, hard
}
