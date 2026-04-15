//
//  GameScreen.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 28.10.2025.
//

import UIKit

@MainActor
class GameViewController: UIViewController, UITableViewDelegate {
    var gameQuestion: [MultipleQuestion] = []
    var currentQuestionIndex: Int = 0
    var currentQuestion: MultipleQuestion {gameQuestion[currentQuestionIndex]}
    var currentQuestionNumber: Int { currentQuestionIndex + 1 }
    var networkService = QuestionNetworkService()
    let gameView = GameView()
    var answers: [String] = [] {
        didSet {
            self.gameView.answersTableView.reloadData()
        }
    }
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadQuestions()
        setupTableView()
        setupAction()
    }
    
    func updateUI() {
        gameView.questionNumberLabel.text = String(currentQuestionNumber)
        gameView.questionTextLabel.text = currentQuestion.question
        self.answers = currentQuestion.answers
    }
    
    func getQuestions() async throws {
        let questions = try await networkService.fetchBatch(difficulty: .easy, isMultiple: true)
        gameQuestion = questions
        print(gameQuestion.count)
        updateUI()
    }
    
    func loadQuestions() {
        Task {
            do {
                try await getQuestions()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func chooseAnswerAndProceed() async {
        guard selectedIndexPath != nil else { return }
        let allCells = gameView.answersTableView.visibleCells.compactMap{ $0 as? AnswerCell}
        for cell in allCells {
            let isCorrect = cell.wordLabel.text == currentQuestion.correctAnswer
            cell.updateColorForResult(isCorrect)
        }
                
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        selectedIndexPath = nil
        goToNextQuestion()
        gameView.nextButton.isEnabled = false
    }
    
    func checkAnswer() -> Bool {
        guard let selectedAnswerRow = self.selectedIndexPath?.row else {
            return false
        }
        let selectedAnswerText = answers[selectedAnswerRow]
        return selectedAnswerText == currentQuestion.correctAnswer
    }
    
    func goToNextQuestion() {
        self.currentQuestionIndex += 1
        
        if self.currentQuestionIndex == 3 {
            Task {
                do {
                    let questions = try await networkService.fetchBatch(difficulty: .medium, isMultiple: true)
                    gameQuestion.append(contentsOf: questions)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        else if self.currentQuestionIndex == 9 {
            Task {
                do {
                    let questions = try await networkService.fetchBatch(difficulty: .hard, isMultiple: true)
                    gameQuestion.append(contentsOf: questions)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        updateUI()
    }
    
    func setupAction() {
        gameView.nextButton.addAction(UIAction { [weak self] _ in
            Task {
                await self?.chooseAnswerAndProceed()
            }
        }, for: .touchUpInside)
    }
    
    func setupTableView() {
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
        gameView.nextButton.isEnabled = true
        tableView.reloadData()
        print(indexPath.row)
    }

}
