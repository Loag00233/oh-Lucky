//
//  QuizGame.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 26.06.2026.
//

import Foundation

class QuizGame {
    
    var gameQuestion: [MultipleQuestion] = []
    var currentQuestionIndex: Int = 0
    var currentQuestion: MultipleQuestion {gameQuestion[currentQuestionIndex]}
    var currentQuestionNumber: Int { currentQuestionIndex + 1 }
    var currentAnswers: [String] = []
    
    func isCorrect(_ answer: String) -> Bool {
        answer == currentQuestion.correctAnswer
    }
    
    func prepareAnswers() {
        var ans = currentQuestion.incorrectAnswers ?? []
        if let correct = currentQuestion.correctAnswer {
            ans.append(correct)
        }
        currentAnswers = ans.shuffled()
    }
    
    func goToNext() {
        currentQuestionIndex += 1
        prepareAnswers()
    }
    
    
}
