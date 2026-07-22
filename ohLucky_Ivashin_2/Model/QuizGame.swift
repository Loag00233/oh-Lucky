//
//  QuizGame.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 26.06.2026.
//

import Foundation

class QuizGame {

    let totalQuestionsCount = 15

    var gameQuestion: [MultipleQuestion] = []
    var currentQuestionIndex: Int = 0
    var currentQuestion: MultipleQuestion {gameQuestion[currentQuestionIndex]}
    var currentQuestionNumber: Int { currentQuestionIndex + 1 }
    var currentAnswers: [String] = []
    var correctAnswersCount: Int = 0

    var isLastQuestion: Bool {
        currentQuestionIndex >= totalQuestionsCount - 1
    }

    func isCorrect(_ answer: String) -> Bool {
        answer == currentQuestion.correctAnswer
    }

    func registerAnswer(_ answer: String) {
        if isCorrect(answer) {
            correctAnswersCount += 1
        }
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
