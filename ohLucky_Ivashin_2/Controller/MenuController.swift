//
//  MenuController.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivashin Ivan on 19.10.2025.
//

import UIKit

class MenuController: UIViewController {
    let mainView = MenuView()

    /// Заставка играет один раз за запуск, а не при каждом возврате из модалки.
    private var isIntroPlayed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = self.mainView
        self.view.backgroundColor = .bgCol
        self.mainView.frame = view.bounds
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mainView.prepareIntro()
        addActions()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageDidChange),
                                               name: .appLanguageDidChange,
                                               object: nil)
    }

    @objc private func languageDidChange() {
        mainView.applyLocalization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isIntroPlayed else { return }
        isIntroPlayed = true
        mainView.playIntro()
    }
    
    func addActions() {
        let startAction = UIAction {
            [weak self] _ in
            let vc = CategoryViewController()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }
        
        mainView.startButton.addAction(startAction, for: .touchUpInside)

        let statisticAction = UIAction {
            [weak self] _ in
            let vc = StatisticsViewController()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }

        mainView.statisticButton.addAction(statisticAction, for: .touchUpInside)

        let settingsAction = UIAction {
            [weak self] _ in
            let vc = SettingsViewController()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }

        mainView.settingsButton.addAction(settingsAction, for: .touchUpInside)
    }
}

