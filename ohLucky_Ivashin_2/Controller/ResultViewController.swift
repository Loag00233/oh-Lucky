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
    var onBackToMenu: (() -> Void)?

    init(correctAnswersCount: Int, totalQuestionsCount: Int) {
        self.correctAnswersCount = correctAnswersCount
        self.totalQuestionsCount = totalQuestionsCount
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = resultView
        resultView.scoreLabel.text = "\(correctAnswersCount) из \(totalQuestionsCount) верно"
        setupActions()
    }

    func setupActions() {
        resultView.onMenuTapped = { [weak self] in
            self?.onBackToMenu?()
        }
    }
}
