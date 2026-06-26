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
    
}

enum Difficulty: String, Decodable {
    case easy, medium, hard
}
