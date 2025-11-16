//
//  GameScreen.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 28.10.2025.
//

import UIKit

class GameViewController: UIViewController, UITableViewDelegate {
    let gameView = GameView()
    var answers: [String] = [] {
        didSet {
            self.gameView.answersTableView.reloadData()
        }
    }
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if answers.isEmpty {
            answers = ["Лиса", "Кот", "Слон", "Олень"]
        }
            
        self.view = gameView
        gameView.answersTableView.dataSource = self
        gameView.answersTableView.delegate = self
    }
}

extension GameViewController: UITableViewDataSource {

    //MARK: высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    //MARK: задано количество ячеек
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }

    //MARK: ячейка создана и если выбрана, то изменяет цвет
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnswerCell.reusedID) as! AnswerCell
        
        let answerText = answers[indexPath.row]
        cell.wordLabel.text = answerText

        switch indexPath.row {
        case 0: cell.letterLabel.text = "A"
        case 1: cell.letterLabel.text = "B"
        case 2: cell.letterLabel.text = "C"
        case 3: cell.letterLabel.text = "D"
        default: break
        }

        let isSelected = (selectedIndexPath == indexPath)
        cell.updateColorOfSelectedCell(isSelected)

        return cell
    }

    //MARK: ячейка выбрана
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.reloadData()
        print(indexPath.row)
    }

}
