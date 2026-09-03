//
//  GameScreen.swift
//  OhLuckyQuiz
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
    /// Свой диалог выхода: закрывать по таймауту можно только его, а не всё, что оказалось на экране.
    private weak var quitAlert: UIAlertController?
    private var tickTimer: Timer?
    /// Варианты, убранные подсказкой на текущем вопросе.
    private var hiddenAnswers: Set<String> = []
    private var lastTickedSecond: Int?

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

        Task { await getQuestions() }
        setupTableView()
        setupAction()
        Haptics.prepare()

        // из фона возвращаемся с уже истёкшим сроком — пересчитываем сразу, не дожидаясь тика
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTicking()
    }

    func updateUI() {
        gameView.isUserInteractionEnabled = true
        hiddenAnswers = []
        gameView.setLoading(false)
        gameView.updateProgress(questionNumber: game.currentQuestionNumber, total: game.totalQuestionsCount)
        gameView.questionNumberLabel.text = localized("Question \(game.currentQuestionNumber)/\(game.totalQuestionsCount):")
        gameView.questionTextLabel.text = game.currentQuestion.question
        gameView.bankMoneyLabel.text = game.bankedAmount.formattedScore
        gameView.bankQuestionSumSubLabel.text = game.currentQuestionSum.formattedScore
        self.answers = game.currentAnswers

        game.startTimer()
        startTicking()
    }

    // MARK: - Таймер

    private func startTicking() {
        tickTimer?.invalidate()
        lastTickedSecond = nil
        refreshTimer()

        // 0.2 с, а не 1: секунда на экране должна меняться сразу после дедлайна, без запаздывания
        tickTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refreshTimer() }
        }
    }

    private func stopTicking() {
        tickTimer?.invalidate()
        tickTimer = nil
        game.stopTimer()
    }

    private func refreshTimer() {
        guard game.questionDeadline != nil else { return }

        let remaining = game.remainingSeconds()
        gameView.setTimer(seconds: remaining, isUrgent: remaining <= 5)

        // тиканье превращает цифру в напряжение, поэтому только на последних пяти секундах
        if remaining <= 5, remaining > 0, lastTickedSecond != remaining {
            lastTickedSecond = remaining
            SoundPlayer.play(.tick)
        }

        // таймер глушим здесь же: guard выше не пустит второй таймаут, пока задача ещё не стартовала
        if game.isTimeUp() {
            stopTicking()
            Task { await finishQuestion(chosen: nil) }
        }
    }

    @objc private func appDidBecomeActive() {
        refreshTimer()
    }

    func getQuestions() async {
        let questions = await fetchQuestionsWithFallback(difficulty: .easy)
        guard !questions.isEmpty else { return }
        StatsStore.recordGameStarted()
        game.gameQuestion = questions
        game.prepareAnswers()
        updateUI()
    }

    /// Пытается получить вопросы с сервера; при ошибке спрашивает пользователя про оффлайн-режим.
    /// Русский язык обслуживается только локальным банком — русских вопросов OpenTDB не отдаёт.
    func fetchQuestionsWithFallback(difficulty: Difficulty) async -> [MultipleQuestion] {
        if isOffline || QuestionSource.current == .offline {
            return OfflineQuestionProvider.loadQuestions(category: category, difficulty: difficulty)
        }

        do {
            return try await networkService.fetchBatch(category: category, difficulty: difficulty)
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
    
    /// Одна ветка на ответ и на таймаут: не успел = ответил неверно.
    private func finishQuestion(chosen: String?) async {
        let spentSeconds = game.elapsedSeconds() // до stopTicking: он обнуляет дедлайн
        stopTicking() // до анимации показа ответа: иначе таймер добежит до нуля прямо во время неё


        gameView.isUserInteractionEnabled = false
        gameView.nextButton.isEnabled = false
        quitAlert?.dismiss(animated: false)

        if chosen == nil { selectedIndexPath = nil }

        let isCorrect = chosen.map(game.isCorrect) ?? false
        if let difficulty = game.currentQuestion.difficulty {
            StatsStore.recordAnswer(category: category,
                                    difficulty: difficulty,
                                    isCorrect: isCorrect,
                                    seconds: spentSeconds)
        }
        if let chosen { game.registerAnswer(chosen) }

        if let selectedIndexPath {
            let selectedCell = gameView.answersTableView.cellForRow(at: selectedIndexPath) as? AnswerCell
            selectedCell?.pulseSelected()
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            selectedCell?.stopPulse()
        }

        Haptics.answer(isCorrect: isCorrect)
        SoundPlayer.play(isCorrect ? .correct : .wrong)
        revealAnswers()

        try? await Task.sleep(nanoseconds: 1_000_000_000)
        selectedIndexPath = nil

        if isCorrect {
            await goToNextQuestion()
        } else {
            showResults(earnedAmount: game.safetyNetAmount, outcome: chosen == nil ? .timedOut : .lost)
        }
    }

    /// Подсветка итога: правильный вариант зелёным, выбранный неверный — красным.
    private func revealAnswers() {
        for cell in gameView.answersTableView.visibleCells.compactMap({ $0 as? AnswerCell }) {
            guard let indexPath = gameView.answersTableView.indexPath(for: cell) else { continue }
            if game.isCorrect(answers[indexPath.row]) {
                cell.apply(.correct)
            } else if indexPath == selectedIndexPath {
                cell.apply(.wrong)
            }
        }
    }


    func goToNextQuestion() async {
        if game.isLastQuestion {
            showResults(earnedAmount: game.bankedAmount, outcome: .won)
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
                showResults(earnedAmount: game.bankedAmount, outcome: .quit)
                return
            }
        }

        game.goToNext()
        updateUI()
    }

    func showResults(earnedAmount: Int, outcome: GameOutcome) {
        stopTicking()
        SoundPlayer.play(.gameover)

        StatsStore.recordGameFinished(earnedAmount: earnedAmount,
                                      correctAnswers: game.correctAnswersCount,
                                      outcome: outcome,
                                      usedHint: !game.isHintAvailable)

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
        gameView.onNextTapped = { [weak self] in
            guard let self, let selectedIndexPath else { return }
            Task { await self.finishQuestion(chosen: self.answers[selectedIndexPath.row]) }
        }

        gameView.onFiftyFiftyTapped = { [weak self] in
            guard let self, game.isHintAvailable else { return }

            hiddenAnswers = game.useHint()
            gameView.setHintUsed()

            if let selected = selectedIndexPath, hiddenAnswers.contains(answers[selected.row]) {
                selectedIndexPath = nil
                gameView.nextButton.isEnabled = false
            }

            gameView.answersTableView.reloadData()
        }

        gameView.onQuitTapped = { [weak self] in
            guard let self else { return }

            let message = game.bankedAmount > 0
                ? localized("Take \(game.bankedAmount.formattedScore) and quit?")
                : localized("Do you really want to quit?")

            let alert = UIAlertController(title: nil,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("Yes"), style: .default) { [weak self] _ in
                guard let self else { return }
                // досрочный выход отдаёт банк — последнюю взятую ступень, иначе нажимать «Выйти» нет смысла
                self.showResults(earnedAmount: self.game.bankedAmount, outcome: .quit)
            })
            alert.addAction(UIAlertAction(title: localized("No"), style: .cancel) { _ in
            })
            self.quitAlert = alert
            self.present(alert, animated: true)
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

        if hiddenAnswers.contains(answerText) {
            cell.apply(.eliminated)
        } else {
            cell.apply(selectedIndexPath == indexPath ? .selected : .normal)
        }

        return cell
    }

    //MARK: ячейка выбрана
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !hiddenAnswers.contains(answers[indexPath.row]) else { return }
        Haptics.tap()
        selectedIndexPath = indexPath
        gameView.nextButton.isEnabled = true
        tableView.reloadData()
    }

}
