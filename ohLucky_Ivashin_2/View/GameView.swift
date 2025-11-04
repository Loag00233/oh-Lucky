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
    
    lazy var bankLabel = UILabel(text: "В банке:")
    lazy var bankMoneyLabel = UILabel(text: "0")
    lazy var bankSubLabel = UILabel(text: "Стоимость вопроса:")
    lazy var bankQuestionSumSubLabel = UILabel(text: "0")
    
    lazy var questionNumberLabel = UILabel(text: "Вопрос 0/0:", isBold: true, isLarge: true, alignement: .left)
    lazy var questionTextLabel = UILabel(text: "Текст вопроса, на который нужно ответить игроку и желательно правильно", isBold: true, isLarge: true, alignement: .left)
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Далее", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        btn.backgroundColor = .menuBtns
        btn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 334).isActive = true
        btn.layer.cornerRadius = 23

        return btn
    }()
    
    lazy var quitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Выйти", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.layer.cornerRadius = 12

        return btn
    }()
    
    lazy var answersTableView = UITableView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setViews()
        setConstraints()
    }

    func setViews() {
        bankLabel.boldDecoration()
        bankMoneyLabel.boldDecoration()
        bankSubLabel.regularDecoration()
        bankQuestionSumSubLabel.regularDecoration()
        
        questionNumberLabel.textColor = .white
        questionTextLabel.textColor = .white
        
        questionTextLabel.numberOfLines = 0 // чтобы переносился по строчкам, В констрейны у правого трейлинга добавил lessThanOrEqualTo
        
        answersTableView.backgroundColor = .clear
        answersTableView.register(AnswerCell.self, forCellReuseIdentifier: AnswerCell.reusedID)
        
        let answer1 = AnswerCell(style: .default, reuseIdentifier: "AnswerCell")
        answer1.frame = CGRect(x: 0, y: 0, width: 334, height: 63)
        let answer2 = AnswerCell(style: .default, reuseIdentifier: "AnswerCell")
        answer2.frame = CGRect(x: 0, y: 70, width: 334, height: 63)
        let answer3 = AnswerCell(style: .default, reuseIdentifier: "AnswerCell")
        answer3.frame = CGRect(x: 0, y: 140, width: 334, height: 63)
        let answer4 = AnswerCell(style: .default, reuseIdentifier: "AnswerCell")
        answer4.frame = CGRect(x: 0, y: 210, width: 334, height: 63)
        answersTableView.addSubview(answer1)
        answersTableView.addSubview(answer2)
        answersTableView.addSubview(answer3)
        answersTableView.addSubview(answer4)
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
        
        addSubview(questionNumberLabel)
        addSubview(questionTextLabel)
        
        addSubview(answersTableView)
        
        addSubview(nextButton)
        
        
        rectangleBankView.translatesAutoresizingMaskIntoConstraints = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        moneyPicView.translatesAutoresizingMaskIntoConstraints = false
        
        bankLabel.translatesAutoresizingMaskIntoConstraints = false
        bankMoneyLabel.translatesAutoresizingMaskIntoConstraints = false
        bankSubLabel.translatesAutoresizingMaskIntoConstraints = false
        bankQuestionSumSubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        answersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            rectangleBankView.centerXAnchor.constraint(equalTo: centerXAnchor),
            rectangleBankView.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            rectangleBankView.widthAnchor.constraint(equalToConstant: 334),
            rectangleBankView.heightAnchor.constraint(equalToConstant: 125)
        ])
        
        NSLayoutConstraint.activate([
            moneyPicView.trailingAnchor.constraint(equalTo: rectangleBankView.trailingAnchor, constant:  -10),
            moneyPicView.topAnchor.constraint(equalTo: rectangleBankView.topAnchor, constant: -10),
            moneyPicView.widthAnchor.constraint(equalToConstant: 102),
            moneyPicView.heightAnchor.constraint(equalToConstant: 91)
        ])
        
        NSLayoutConstraint.activate([
            quitButton.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant:  10),
            quitButton.topAnchor.constraint(equalTo: rectangleBankView.topAnchor, constant: 18),
        ])
        
        NSLayoutConstraint.activate([
            bankLabel.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant:  14),
            bankLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -43),
        ])
        
        NSLayoutConstraint.activate([
            bankMoneyLabel.leadingAnchor.constraint(equalTo: bankLabel.trailingAnchor, constant:  4),
            bankMoneyLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -43),
        ])
        
        NSLayoutConstraint.activate([
            bankSubLabel.leadingAnchor.constraint(equalTo: rectangleBankView.leadingAnchor, constant: 14),
            bankSubLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -21),
        ])
        
        NSLayoutConstraint.activate([
            bankQuestionSumSubLabel.leadingAnchor.constraint(equalTo: bankSubLabel.trailingAnchor, constant: 4),
            bankQuestionSumSubLabel.bottomAnchor.constraint(equalTo: rectangleBankView.bottomAnchor, constant: -21),
        ])
        
        
        NSLayoutConstraint.activate([
            questionNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 33),
            questionNumberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 317),
        ])
        
        NSLayoutConstraint.activate([
            questionTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 33),
            questionTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10), // прикол да?
            questionTextLabel.topAnchor.constraint(equalTo: questionNumberLabel.bottomAnchor, constant: 5),
        ])
        
        NSLayoutConstraint.activate([
            answersTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            answersTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
            answersTableView.topAnchor.constraint(equalTo: questionTextLabel.bottomAnchor, constant: 20),
            answersTableView.bottomAnchor.constraint(equalTo:  bottomAnchor, constant: 63)
        ])
        
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -56),
            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
        ])
        
    }


    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }
    
}

#Preview {
    GameView()
}
