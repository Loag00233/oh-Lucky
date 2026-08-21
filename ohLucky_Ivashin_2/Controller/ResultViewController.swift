//
//  ResultViewController.swift
//  ohLucky_Ivashin_2
//

import UIKit

@MainActor
class ResultViewController: UIViewController {

    let resultView = ResultView()
    let correctAnswersCount: Int
    let totalQuestionsCount: Int
    let earnedAmountText: String
    var onBackToMenu: (() -> Void)?

    init(correctAnswersCount: Int, totalQuestionsCount: Int, earnedAmountText: String) {
        self.correctAnswersCount = correctAnswersCount
        self.totalQuestionsCount = totalQuestionsCount
        self.earnedAmountText = earnedAmountText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = resultView
        resultView.scoreLabel.text = String(localized: "\(correctAnswersCount) of \(totalQuestionsCount) correct\nEarned: \(earnedAmountText)")
        setupActions()
    }

    func setupActions() {
        resultView.onMenuTapped = { [weak self] in
            self?.onBackToMenu?()
        }
    }
}
