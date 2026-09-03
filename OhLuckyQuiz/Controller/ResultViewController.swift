//
//  ResultViewController.swift
//  OhLuckyQuiz
//

import StoreKit
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askForReviewIfEarned()
    }

    /// Просим оценку только у того, кто дошёл до конца и играет не первый раз:
    /// проигравшему новичку это предложение читается как издевательство.
    private func askForReviewIfEarned() {
        guard correctAnswersCount == totalQuestionsCount,
              StatsStore.load().gamesPlayed >= 3,
              let scene = view.window?.windowScene else { return }

        SKStoreReviewController.requestReview(in: scene)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = resultView
        resultView.scoreLabel.text = localized("\(correctAnswersCount) of \(totalQuestionsCount) correct\nEarned: \(earnedAmountText)")
        setupActions()
        showNewAchievements()
    }

    /// Итог партии уже записан в статистику к этому моменту, поэтому свежие достижения
    /// считаются здесь, а не на экране игры.
    private func showNewAchievements() {
        let fresh = AchievementsStore.consumeNewlyUnlocked(in: StatsStore.load())
        guard let first = fresh.first else { return }

        let text = fresh.count > 1
            ? localized("New achievement: \(first.title) +\(fresh.count - 1)")
            : localized("New achievement: \(first.title)")
        resultView.showAchievementToast(text)
    }

    func setupActions() {
        resultView.onMenuTapped = { [weak self] in
            self?.onBackToMenu?()
        }
    }
}
