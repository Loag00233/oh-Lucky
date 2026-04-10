//
//  Question.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

struct MultipleQuestion: Decodable {
    
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let difficulty: String
    
    var answers: [String] {
        var ans = incorrectAnswers
        ans.append(correctAnswer)
        return ans.shuffled()
    }
    
    var diff: Difficulty {
        switch difficulty {
        case "easy": return .easy
        case "medium": return .medium
        default: return .hard
        }
    }
}

enum Difficulty: String {
    case easy, medium, hard
}
