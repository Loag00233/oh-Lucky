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
    private var nextBatchTask: Task<Void, Never>?
    private var isAnswerLocked = false

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
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadQuestions()
        setupTableView()
        setupAction()
    }
    
    func updateUI() {
        isAnswerLocked = false
        gameView.setLoading(false)
        gameView.updateProgress(questionNumber: game.currentQuestionNumber, total: game.totalQuestionsCount)
        gameView.questionNumberLabel.text = localized("Question \(game.currentQuestionNumber)/\(game.totalQuestionsCount):")
        gameView.questionTextLabel.text = game.currentQuestion.question
        gameView.bankMoneyLabel.text = game.bankedAmount.formattedScore
        gameView.bankQuestionSumSubLabel.text = game.currentQuestionSum.formattedScore
        self.answers = game.currentAnswers
    }
    
    func getQuestions() async {
        let questions = await fetchQuestionsWithFallback(difficulty: .easy)
        guard !questions.isEmpty else { return }
        StatsStore.recordGameStarted()
        game.gameQuestion = questions
        game.prepareAnswers()
        updateUI()
    }

    func loadQuestions() {
        Task {
            await getQuestions()
        }
    }

    /// Пытается получить вопросы с сервера; при ошибке спрашивает пользователя про оффлайн-режим.
    /// Русский язык обслуживается только локальным банком — русских вопросов OpenTDB не отдаёт.
    func fetchQuestionsWithFallback(difficulty: Difficulty) async -> [MultipleQuestion] {
        if isOffline || AppLanguage.current == .ru {
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
                                           message: localized("No connection to the server. Switch to offline mode?"),
                                           preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("Yes"), style: .default) { [weak self] _ in
                self?.isOffline = true
                continuation.resume(returning: OfflineQuestionProvider.loadQuestions(category: self?.category ?? .generalKnowledge, difficulty: difficulty))
            })
            alert.addAction(UIAlertAction(title: localized("No"), style: .cancel) { [weak self] _ in
                self?.presentingViewController?.presentingViewController?.dismiss(animated: true)
                continuation.resume(returning: [])
            })
            present(alert, animated: true)
        }
    }
    
    func chooseAnswerAndProceed() async {
        guard let selectedIndexPath = selectedIndexPath else { return }

        let chosenAnswer = answers[selectedIndexPath.row]
        if let difficulty = game.currentQuestion.difficulty {
            StatsStore.recordAnswer(category: category, difficulty: difficulty, isCorrect: game.isCorrect(chosenAnswer))
        }
        game.registerAnswer(chosenAnswer)

        let selectedCell = gameView.answersTableView.cellForRow(at: selectedIndexPath) as? AnswerCell
        selectedCell?.pulseSelected()
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        selectedCell?.stopPulse()

        let isChosenCorrect = game.isCorrect(chosenAnswer)
        UINotificationFeedbackGenerator().notificationOccurred(isChosenCorrect ? .success : .error)

        let allCells = gameView.answersTableView.visibleCells.compactMap{ $0 as? AnswerCell}
        for cell in allCells {
            guard let indexPath = gameView.answersTableView.indexPath(for: cell) else { continue }
            let isCorrect = game.isCorrect(cell.wordLabel.text ?? "")
            if isCorrect || indexPath == selectedIndexPath {
                cell.updateColorForResult(isCorrect)
            }
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.selectedIndexPath = nil

        if isChosenCorrect {
            await goToNextQuestion()
            gameView.nextButton.isEnabled = false
        } else {
            showResults(earnedAmount: game.safetyNetAmount)
        }
    }


    func goToNextQuestion() async {
        if game.isLastQuestion {
            showResults(earnedAmount: game.bankedAmount)
            return
        }

        let nextIndex = game.currentQuestionIndex + 1

        // партии по 5 вопросов. На 4-м легком вопросе (индекс 3) заранее подгружаем medium
        if nextIndex == 3 {
            nextBatchTask = Task {
                let questions = await fetchQuestionsWithFallback(difficulty: .medium)
                game.gameQuestion.append(contentsOf: questions)
            }
        }
        // на 10-м вопросе (индекс 9), последнем в medium-партии, заранее подгружаем hard
        else if nextIndex == 9 {
            nextBatchTask = Task {
                let questions = await fetchQuestionsWithFallback(difficulty: .hard)
                game.gameQuestion.append(contentsOf: questions)
            }
        }

        if nextIndex >= game.gameQuestion.count {
            gameView.setLoading(true)
            await nextBatchTask?.value
            gameView.setLoading(false)

            // догрузка не дала вопросов (например, отказ от оффлайн-режима) — завершаем партию, не падаем по индексу
            if nextIndex >= game.gameQuestion.count {
                showResults(earnedAmount: game.bankedAmount)
                return
            }
        }

        game.goToNext()
        updateUI()
    }

    func showResults(earnedAmount: Int) {
        StatsStore.recordGameFinished(earnedAmount: earnedAmount)

        let resultVC = ResultViewController(correctAnswersCount: game.correctAnswersCount,
                                             totalQuestionsCount: game.totalQuestionsCount,
                                             earnedAmountText: earnedAmount.formattedScore)
        resultVC.modalPresentationStyle = .fullScreen
        resultVC.onBackToMenu = { [weak self] in
            self?.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
        present(resultVC, animated: true)
    }
    
    func setupAction() {
        gameView.onNextTapped = {[weak self] in
            self?.gameView.nextButton.isEnabled = false
            self?.isAnswerLocked = true
            Task { await self?.chooseAnswerAndProceed() }
        }

        
        
        
        
        gameView.onQuitTapped = { [weak self] in
            let alert = UIAlertController(title: nil,
                                          message: localized("Do you really want to quit?"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("Yes"), style: .default) { [weak self] _ in
                guard let self else { return }
                // при досрочном выходе засчитываем несгораемую сумму (0, если правильных ответов меньше 5)
                StatsStore.recordGameFinished(earnedAmount: self.game.safetyNetAmount)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
            })
            alert.addAction(UIAlertAction(title: localized("No"), style: .cancel) { _ in
            })
            self?.present(alert, animated: true)
            
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

        cell.accessibilityIdentifier = "game.answerCell.\(indexPath.row)"

        let isSelected = (selectedIndexPath == indexPath)
        cell.updateColorOfSelectedCell(isSelected)

        return cell
    }

    //MARK: ячейка выбрана
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isAnswerLocked else { return }
        selectedIndexPath = indexPath
        gameView.nextButton.isEnabled = true
        tableView.reloadData()
    }

}
