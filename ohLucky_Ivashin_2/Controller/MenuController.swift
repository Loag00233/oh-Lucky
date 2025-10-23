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
    }
}

