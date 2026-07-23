//
//  GameScreen.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 28.10.2025.
//

import UIKit

@MainActor
class GameViewController: UIViewController, UITableViewDelegate {
    
    let game = QuizGame()
    
    let networkService: QuestionNetworkServiceType
    let category: QuizCategory
    let gameView = GameView()
    var answers: [String] = [] {
        didSet {
            self.gameView.answersTableView.reloadData()
        }
    }
    var selectedIndexPath: IndexPath?
    var isOffline = false

    #if DEBUG
    private let debugAnswerSets: [[String]] = [
        ["Yes", "No", "Maybe", "Perhaps"],
        ["Short", "Sheep's Heart, Kidneys and Lungs", "A", "B"],
        ["The Assassination of Archduke Franz Ferdinand of Austria", "Short", "Medium length answer here", "X"]
    ]
    private var debugAnswerSetIndex = 0
    #endif

    init(networkService: QuestionNetworkServiceType, category: QuizCategory) {
        self.networkService = networkService
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadQuestions()
        setupTableView()
        setupAction()
    }
    
    func updateUI() {
        gameView.setLoading(false)
        gameView.questionNumberLabel.text = String(game.currentQuestionNumber)
        gameView.questionTextLabel.text = game.currentQuestion.question
        self.answers = game.currentAnswers
    }
    
    func getQuestions() async {
        let questions = await fetchQuestionsWithFallback(difficulty: .easy)
        guard !questions.isEmpty else { return }
        game.gameQuestion = questions
        game.prepareAnswers()
        updateUI()
    }

    func loadQuestions() {
        Task {
            await getQuestions()
        }
    }

    /// Пытается получить вопросы с сервера; при ошибке спрашивает пользователя про оффлайн-режим
    func fetchQuestionsWithFallback(difficulty: Difficulty) async -> [MultipleQuestion] {
        if isOffline {
            return OfflineQuestionProvider.loadQuestions(category: category, difficulty: difficulty)
        }

        do {
            return try await networkService.fetchBatch(category: category, difficulty: difficulty, isMultiple: true)
        } catch {
            return await promptOfflineFallback(difficulty: difficulty)
        }
    }

    func promptOfflineFallback(difficulty: Difficulty) async -> [MultipleQuestion] {
        await withCheckedContinuation { continuation in
            let alert = UIAlertController(title: nil,
                                           message: "Нет связи с сервером. Переключиться в оффлайн режим?",
                                           preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                self?.isOffline = true
                continuation.resume(returning: OfflineQuestionProvider.loadQuestions(category: self?.category ?? .generalKnowledge, difficulty: difficulty))
            })
            alert.addAction(UIAlertAction(title: "Нет", style: .cancel) { [weak self] _ in
                self?.presentingViewController?.dismiss(animated: true)
                continuation.resume(returning: [])
            })
            present(alert, animated: true)
        }
    }
    
    func chooseAnswerAndProceed() async {
        guard let selectedIndexPath = selectedIndexPath else { return }

        let chosenAnswer = answers[selectedIndexPath.row]
        game.registerAnswer(chosenAnswer)

        let allCells = gameView.answersTableView.visibleCells.compactMap{ $0 as? AnswerCell}
        for cell in allCells {
            let isCorrect = game.isCorrect(cell.wordLabel.text ?? "")
            cell.updateColorForResult(isCorrect)
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.selectedIndexPath = nil
        goToNextQuestion()
        gameView.nextButton.isEnabled = false
    }


    func goToNextQuestion() {
        if game.isLastQuestion {
            showResults()
            return
        }

        game.goToNext()

        if game.currentQuestionIndex == 3 {
            Task {
                let questions = await fetchQuestionsWithFallback(difficulty: .medium)
                game.gameQuestion.append(contentsOf: questions)
            }
        }
        else if game.currentQuestionIndex == 9 {
            Task {
                let questions = await fetchQuestionsWithFallback(difficulty: .hard)
                game.gameQuestion.append(contentsOf: questions)
            }
        }
        updateUI()
    }

    func showResults() {
        let resultVC = ResultViewController(correctAnswersCount: game.correctAnswersCount,
                                             totalQuestionsCount: game.totalQuestionsCount)
        resultVC.modalPresentationStyle = .fullScreen
        resultVC.onBackToMenu = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true)
        }
        present(resultVC, animated: true)
    }
    
    func setupAction() {
        gameView.onNextTapped = {[weak self] in
            Task { await self?.chooseAnswerAndProceed() }
        }

        gameView.onQuitTapped = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true)
        }

        #if DEBUG
        // долгий тап по quitButton — переключить набор тестовых ответов (по кругу), тап "Далее" — выйти обратно к реальным вопросам
        gameView.onDebugLongPress = { [weak self] in
            guard let self else { return }
            self.answers = self.debugAnswerSets[self.debugAnswerSetIndex]
            self.debugAnswerSetIndex = (self.debugAnswerSetIndex + 1) % self.debugAnswerSets.count
        }
        #endif
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
        UITableView.automaticDimension
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
    }

}
