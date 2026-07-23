//
//  MenuController.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivashin Ivan on 19.10.2025.
//

import UIKit

class MenuController: UIViewController {
    let mainView = MenuView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = self.mainView
        self.view.backgroundColor = .bgCol
        self.mainView.frame = view.bounds
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addActions()
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
    }
}

