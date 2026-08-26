//
//  StatisticsViewController.swift
//  OhLuckyQuiz
//

import UIKit

final class StatisticsViewController: UIViewController {

    private let statisticsView = StatisticsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view = statisticsView
        statisticsView.render(StatsStore.load())
        statisticsView.onBackTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
