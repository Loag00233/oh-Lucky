//
//  QuizGame.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 26.06.2026.
//

import Foundation

class QuizGame {

    let totalQuestionsCount = 15

    private static let prizeLadder: [Int] = [
        100, 200, 300, 500, 1_000,
        2_000, 4_000, 8_000, 16_000, 32_000,
        64_000, 125_000, 250_000, 500_000, 1_000_000
    ]

    var gameQuestion: [MultipleQuestion] = []
    var currentQuestionIndex: Int = 0
    var currentQuestion: MultipleQuestion {gameQuestion[currentQuestionIndex]}
    var currentQuestionNumber: Int { currentQuestionIndex + 1 }
    var currentAnswers: [String] = []
    var correctAnswersCount: Int = 0
    private(set) var bankedAmount: Int = 0

    var currentQuestionSum: Int { Self.prizeLadder[currentQuestionIndex] }

    /// Несгораемая сумма: сохраняется при проигрыше, даже если банк был больше.
    var safetyNetAmount: Int {
        if correctAnswersCount >= 10 { return Self.prizeLadder[9] }
        if correctAnswersCount >= 5 { return Self.prizeLadder[4] }
        return 0
    }

    var isLastQuestion: Bool {
        currentQuestionIndex >= totalQuestionsCount - 1
    }

    func isCorrect(_ answer: String) -> Bool {
        answer == currentQuestion.correctAnswer
    }

    func registerAnswer(_ answer: String) {
        if isCorrect(answer) {
            correctAnswersCount += 1
            bankedAmount += Self.prizeLadder[currentQuestionIndex]
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
