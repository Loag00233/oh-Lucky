//
//  GameView.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 28.10.2025.
//

import UIKit

class GameView: UIView {
    
    lazy var rectangleBankView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rectBankView
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var moneyPicView: UIImageView = {
        let money = UIImageView()
        money.image = UIImage(named: "money.png")
        money.contentMode = .scaleAspectFill
        return money
    }()
    
    lazy var bankLabel = UILabel(text: "Bank:")
    lazy var bankMoneyLabel = UILabel(text: "0")
    lazy var bankSubLabel = UILabel(text: "Question for:")
    lazy var bankQuestionSumSubLabel = UILabel(text: "0")
    
    lazy var questionNumberLabel = UILabel(text: "Question 0/0:", isBold: true, isLarge: true, alignement: .left)
    lazy var questionTextLabel = UILabel(text: "Text of the question that the player must answer, preferably correctly", isBold: true, isLarge: true, alignement: .left)
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.isEnabled = false
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitle("Next", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        btn.backgroundColor = .menuBtns
        btn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        btn.layer.cornerRadius = 23
        btn.accessibilityIdentifier = "game.nextButton"

        return btn
    }()

    lazy var quitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Quit", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.layer.cornerRadius = 12
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

    lazy var loadingLabel = UILabel(text: "Loading questions...", isBold: true, alignement: .center)
    
    lazy var progressBarBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "bankColor")?.cgColor
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }()
    
    lazy var progressGradientLayer: CAGradientLayer = {
        let color = UIColor.makeGradientLayer()
        return color
    }()
    
    lazy var progressBarFillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.insertSublayer(progressGradientLayer, at: 0)
        progressFillWidthConstraint = view.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidthConstraint.isActive = true
        return view
    }()
    
    var progressFillWidthConstraint: NSLayoutConstraint!
    
    private var progressFraction: CGFloat = 0

    var onNextTapped: (() -> Void)?
    var onQuitTapped: (() -> Void)?
    #if DEBUG
    var onDebugLongPress: (() -> Void)?
    #endif
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setViews()
        setConstraints()
        setupActions()
        setLoading(true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressBarBorderView.layer.cornerRadius = progressBarBorderView.bounds.height / 2
        progressBarFillView.layer.cornerRadius = progressBarFillView.bounds.height / 2
        progressBarFillView.layer.masksToBounds = true
        progressGradientLayer.frame = progressBarFillView.bounds
    }

    func setViews() {
        bankLabel.boldBankCardDecoration()
        bankMoneyLabel.boldBankCardDecoration()
        bankSubLabel.regularBankCardDecoration()
        bankQuestionSumSubLabel.regularBankCardDecoration()
        
        questionNumberLabel.textColor = .white
        questionTextLabel.textColor = .white
        questionTextLabel.numberOfLines = 0 // чтобы переносился по строчкам, В констрейны у правого трейлинга добавил lessThanOrEqualTo
        
        answersTableView.backgroundColor = .clear
        answersTableView.register(AnswerCell.self, forCellReuseIdentifier: AnswerCell.reusedID)
        answersTableView.rowHeight = UITableView.automaticDimension
        answersTableView.estimatedRowHeight = 60

        loadingLabel.textColor = .white
    }

    //MARK: добавляем на экран через addsubview, маску авторесайзинга выкл и констрейены
    func setConstraints() {
        addSubview(rectangleBankView)
        addSubview(quitButton)
        addSubview(moneyPicView)
        addSubview(bankLabel)
        addSubview(bankMoneyLabel)
        addSubview(bankSubLabel)
        addSubview(bankQuestionSumSubLabel)
        addSubview(progressBarBorderView)
        addSubview(progressBarFillView)
        addSubview(questionNumberLabel)
        addSubview(questionTextLabel)
        addSubview(answersTableView)
        addSubview(nextButton)
        addSubview(loadingIndicator)
        addSubview(loadingLabel)


        rectangleBankView.translatesAutoresizingMaskIntoConstraints = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        moneyPicView.translatesAutoresizingMaskIntoConstraints = false
        
        bankLabel.translatesAutoresizingMaskIntoConstraints = false
        bankMoneyLabel.translatesAutoresizingMaskIntoConstraints = false
        bankSubLabel.translatesAutoresizingMaskIntoConstraints = false
        bankQuestionSumSubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressBarBorderView.translatesAutoresizingMaskIntoConstraints = false
        progressBarFillView.translatesAutoresizingMaskIntoConstraints = false
        
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        answersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            rectangleBankView.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            rectangleBankView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            rectangleBankView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
            rectangleBankView.heightAnchor.constraint(equalToConstant: 125),
        
            moneyPicView.trailingAnchor.constraint(equalTo: rectangleBankView.trailingAnchor, constant:  -10),
            moneyPicView.topAnchor.constraint(equalTo: rectangleBankView.topAnchor, constant: -10),
            moneyPicView.widthAnchor.constraint(equalToConstant: 102),
            moneyPicView.heightAnchor.constraint(equalToConstant: 91),
        
            quitButton.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant:  10),
            quitButton.topAnchor.constraint(equalTo: rectangleBankView.topAnchor, constant: 18),
        
            bankLabel.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant:  14),
            bankLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -43),
        
            bankMoneyLabel.leadingAnchor.constraint(equalTo: bankLabel.trailingAnchor, constant:  4),
            bankMoneyLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -43),
        
            bankSubLabel.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant: 14),
            bankSubLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -21),
        
            bankQuestionSumSubLabel.leadingAnchor.constraint(equalTo: bankSubLabel.trailingAnchor, constant: 4),
            bankQuestionSumSubLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -21),
        
            
            progressBarBorderView.topAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: 20),
            progressBarBorderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            progressBarBorderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
            
            progressBarFillView.topAnchor.constraint(equalTo: progressBarBorderView.topAnchor, constant: 2),
            progressBarFillView.leadingAnchor.constraint(equalTo: progressBarBorderView.leadingAnchor, constant: 2),
            progressBarFillView.bottomAnchor.constraint(equalTo:
              progressBarBorderView.bottomAnchor, constant: -2),
            
            questionNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 33),
            questionNumberLabel.topAnchor.constraint(equalTo: progressBarBorderView.bottomAnchor, constant: 20),
        
            questionTextLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 5),
            questionTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 33),
            questionTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            
        
            answersTableView.topAnchor.constraint(equalTo: questionTextLabel.bottomAnchor, constant: 20),
            answersTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            answersTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
            answersTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: 20),
        
        
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -56),
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),

            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

    }
    
    func updateProgress(questionNumber: Int, total: Int) {
        let segmentWidth = progressBarBorderView.bounds.width / CGFloat(total)
        progressFillWidthConstraint.constant = segmentWidth * CGFloat(questionNumber)
    }

    //MARK: показывает спиннер вместо вопроса/ответов, пока идёт первая загрузка
    func setLoading(_ isLoading: Bool) {
        loadingIndicator.isHidden = !isLoading
        loadingLabel.isHidden = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()

        questionNumberLabel.isHidden = isLoading
        questionTextLabel.isHidden = isLoading
        answersTableView.isHidden = isLoading
        nextButton.isHidden = isLoading
    }
    
    func setupActions() {
        nextButton.addAction(UIAction { [weak self] _ in
            self?.onNextTapped?()
        }, for: .touchUpInside)

        quitButton.addAction(UIAction { [weak self] _ in
            self?.onQuitTapped?()
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



    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }
    
}

#Preview {
    GameView()
}
