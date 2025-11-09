//
//  GameScreen.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 28.10.2025.
//

import UIKit

class GameViewController: UIViewController {
    let gameView = GameView()
    let answers: [String] = ["Ответ 1", "Ответ 2" ,"Ответ 3" ,"Ответ 4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = self.gameView
    }
}
