//
//  GameView.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 28.10.2025.
//

import UIKit

class GameView: UIView {

    // MARK: - Subviews

    lazy var rectangleBankView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rectBankView
        view.layer.cornerRadius = Radius.card
        view.layer.masksToBounds = true
        return view
    }()

    lazy var moneyPicView: UIImageView = {
        let money = UIImageView()
        money.image = UIImage(named: "money.png")
        money.contentMode = .scaleAspectFill
        return money
    }()

    lazy var bankLabel = UILabel(text: localized("Bank:"))
    lazy var bankMoneyLabel = UILabel(text: "0")
    lazy var bankSubLabel = UILabel(text: localized("Question for:"))
    lazy var bankQuestionSumSubLabel = UILabel(text: "0")

    lazy var timerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .montserrat(26, bold: true)
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.accessibilityIdentifier = "game.timerLabel"
        return lbl
    }()

    lazy var questionNumberLabel = UILabel(text: "", isBold: true, isLarge: true, alignment: .left)
    lazy var questionTextLabel = UILabel(text: "", isBold: true, isLarge: true, alignment: .left)
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.isEnabled = false
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitle(localized("Next"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .montserrat(20, bold: true)
        btn.backgroundColor = .menuBtns
        btn.layer.cornerRadius = Radius.card
        btn.accessibilityIdentifier = "game.nextButton"

        return btn
    }()

    lazy var fiftyFiftyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("50:50", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.black, for: .disabled)
        btn.titleLabel?.font = .montserrat(15, bold: true)
        btn.backgroundColor = .menuBtns
        btn.layer.cornerRadius = Radius.pill(30)
        btn.accessibilityIdentifier = "game.fiftyFiftyButton"

        return btn
    }()

    lazy var quitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(localized("Quit"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .montserrat(16, bold: true)
        btn.backgroundColor = .exitBtnC
        btn.layer.cornerRadius = Radius.pill(32)
        btn.accessibilityIdentifier = "game.quitButton"

        return btn
    }()

    lazy var answersTableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = "game.answersTableView"
        return tableView
    }()

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()

    lazy var loadingLabel = UILabel(text: localized("Loading questions..."), isBold: true, alignment: .center)

    lazy var progressBarBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.bank.cgColor
        return view
    }()
    
    lazy var progressGradientLayer: CAGradientLayer = {
        let color = UIColor.makeGradientLayer()
        return color
    }()

    lazy var progressBarFillView: UIView = {
        let view = UIView()
        view.layer.insertSublayer(progressGradientLayer, at: 0)
        return view
    }()

    var progressBarFillWidth: NSLayoutConstraint!

    private var shownSeconds: Int?

    // MARK: - Callbacks

    var onNextTapped: (() -> Void)?
    var onQuitTapped: (() -> Void)?
    var onFiftyFiftyTapped: (() -> Void)?
    #if DEBUG
    var onDebugLongPress: (() -> Void)?
    #endif

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setViews()
        setConstraints()
        setupActions()
        setLoading(true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        progressBarBorderView.layer.cornerRadius = Radius.pill(progressBarBorderView.bounds.height)
        progressBarFillView.layer.cornerRadius = Radius.pill(progressBarFillView.bounds.height)
        progressBarFillView.layer.masksToBounds = true
        progressGradientLayer.frame = progressBarFillView.bounds
    }

    func setViews() {
        bankLabel.decorate(color: .bank, bold: true)
        bankMoneyLabel.decorate(color: .bank, bold: true)
        bankSubLabel.decorate(color: .bank)
        bankQuestionSumSubLabel.decorate(color: .bank)
        
        questionNumberLabel.textColor = .white
        questionTextLabel.textColor = .white
        questionTextLabel.numberOfLines = 0 // wraps to multiple lines, trailing constraint uses lessThanOrEqualTo
        
        answersTableView.backgroundColor = .clear
        answersTableView.register(AnswerCell.self, forCellReuseIdentifier: AnswerCell.reusedID)
        answersTableView.rowHeight = UITableView.automaticDimension
        answersTableView.estimatedRowHeight = 60

        loadingLabel.textColor = .white
    }

    // adds subviews, disables autoresizing masks and activates constraints
    func setConstraints() {
        let viewsToLayout: [UIView] = [
            rectangleBankView, quitButton, fiftyFiftyButton, moneyPicView,
            bankLabel, bankMoneyLabel, bankSubLabel, bankQuestionSumSubLabel, timerLabel,
            progressBarBorderView, progressBarFillView,
            questionNumberLabel, questionTextLabel,
            answersTableView, nextButton,
            loadingIndicator, loadingLabel
        ]

        viewsToLayout.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        progressBarFillWidth = progressBarFillView.widthAnchor.constraint(equalToConstant: 0)

        let content = makeContentGuide()

        // ширина уступает ограничению «не наезжать на картинку»: на узком экране
        // (iPad в сплите) кнопка сожмётся, а не сломает раскладку
        let hintWidth = fiftyFiftyButton.widthAnchor.constraint(equalToConstant: 66)
        hintWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: 63),
            quitButton.heightAnchor.constraint(equalToConstant: 32),
            fiftyFiftyButton.heightAnchor.constraint(equalToConstant: 30),
            hintWidth,
            quitButton.widthAnchor.constraint(equalToConstant: 100),
            progressBarBorderView.heightAnchor.constraint(equalToConstant: 16),
            progressBarFillWidth,

            rectangleBankView.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            rectangleBankView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            rectangleBankView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            rectangleBankView.heightAnchor.constraint(equalToConstant: 125),
        
            moneyPicView.trailingAnchor.constraint(equalTo: rectangleBankView.trailingAnchor, constant:  -10),
            moneyPicView.topAnchor.constraint(equalTo: rectangleBankView.topAnchor, constant: -10),
            moneyPicView.widthAnchor.constraint(equalToConstant: 102),
            moneyPicView.heightAnchor.constraint(equalToConstant: 91),
        
            quitButton.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant:  10),
            quitButton.topAnchor.constraint(equalTo: rectangleBankView.topAnchor, constant: 18),

            fiftyFiftyButton.leadingAnchor.constraint(equalTo: quitButton.trailingAnchor, constant: 8),
            fiftyFiftyButton.trailingAnchor.constraint(lessThanOrEqualTo: moneyPicView.leadingAnchor, constant: -4),
            fiftyFiftyButton.centerYAnchor.constraint(equalTo: quitButton.centerYAnchor),
        
            bankLabel.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant:  14),
            bankLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -43),
        
            bankMoneyLabel.leadingAnchor.constraint(equalTo: bankLabel.trailingAnchor, constant:  4),
            bankMoneyLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -43),
        
            bankSubLabel.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant: 14),
            bankSubLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -21),
        
            bankQuestionSumSubLabel.leadingAnchor.constraint(equalTo: bankSubLabel.trailingAnchor, constant: 4),
            bankQuestionSumSubLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -21),

            timerLabel.trailingAnchor.constraint(equalTo: rectangleBankView.trailingAnchor, constant: -14),
            timerLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -14),

            
            progressBarBorderView.topAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: 20),
            progressBarBorderView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            progressBarBorderView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            
            progressBarFillView.topAnchor.constraint(equalTo: progressBarBorderView.topAnchor, constant: 2),
            progressBarFillView.leadingAnchor.constraint(equalTo: progressBarBorderView.leadingAnchor, constant: 2),
            progressBarFillView.bottomAnchor.constraint(equalTo:
              progressBarBorderView.bottomAnchor, constant: -2),
            
            questionNumberLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            questionNumberLabel.topAnchor.constraint(equalTo: progressBarBorderView.bottomAnchor, constant: 20),
        
            questionTextLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 5),
            questionTextLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            questionTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor),
            
        
            answersTableView.topAnchor.constraint(equalTo: questionTextLabel.bottomAnchor, constant: 20),
            answersTableView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            answersTableView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            answersTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
        
        
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -56),
            nextButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

    }
    
    // MARK: - Public API

    /// Цифра перерисовывается только при смене секунды: репитер тикает впятеро чаще,
    /// а пульсация на каждом тике переапускалась бы и выглядела дрожью.
    func setTimer(seconds: Int, isUrgent: Bool) {
        timerLabel.textColor = isUrgent ? .wrongAns : .white

        guard shownSeconds != seconds else { return }
        shownSeconds = seconds
        timerLabel.text = "\(seconds)"

        guard isUrgent, !UIAccessibility.isReduceMotionEnabled else { return }
        timerLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        UIView.animate(withDuration: 0.3) { self.timerLabel.transform = .identity }
    }

    /// Кнопка остаётся на месте неактивной: убрать её — значит дёрнуть вёрстку в середине партии.
    func setHintUsed() {
        fiftyFiftyButton.isEnabled = false
        fiftyFiftyButton.alpha = 0.4
    }

    func updateProgress(questionNumber: Int, total: Int) {
        let segmentWidth = (progressBarBorderView.bounds.width - 4) / CGFloat(total)
        progressBarFillWidth?.constant = segmentWidth * CGFloat(questionNumber)
    }

    // shows the spinner instead of the default text of question/answers while the first batch is loading
    func setLoading(_ isLoading: Bool) {
        loadingIndicator.isHidden = !isLoading
        loadingLabel.isHidden = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()

        timerLabel.isHidden = isLoading
        fiftyFiftyButton.isHidden = isLoading
        questionNumberLabel.isHidden = isLoading
        questionTextLabel.isHidden = isLoading
        answersTableView.isHidden = isLoading
        nextButton.isHidden = isLoading
    }
    
    // MARK: - Actions

    func setupActions() {
        nextButton.addAction(UIAction { [weak self] _ in
            self?.onNextTapped?()
        }, for: .touchUpInside)

        quitButton.addAction(UIAction { [weak self] _ in
            self?.onQuitTapped?()
        }, for: .touchUpInside)

        fiftyFiftyButton.addAction(UIAction { [weak self] _ in
            self?.onFiftyFiftyTapped?()
        }, for: .touchUpInside)

        #if DEBUG
        // longtap quitButton — change answers to test strings (layout check)
        let debugLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleDebugLongPress))
        quitButton.addGestureRecognizer(debugLongPress)
        #endif
    }

    #if DEBUG
    @objc private func handleDebugLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onDebugLongPress?()
    }
    #endif
}

#Preview {
    GameView()
}
