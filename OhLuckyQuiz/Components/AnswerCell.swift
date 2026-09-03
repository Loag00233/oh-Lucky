//
//  AnswerCell.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 04.11.2025.
//

import UIKit

class AnswerCell: UITableViewCell {
    
    static let reusedID = "AnswerCell"

    lazy var cardView = UIView() // на нее все кладем, чтобы ячейки могли "разлепиться" друг от друга

    lazy var circleView: UIImageView = {
        let circle = UIImageView()
        circle.image = UIImage(named: "EllipseAnswer")
        circle.contentMode = .scaleAspectFit
        circle.layer.cornerRadius = Radius.pill(32)
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.bank.cgColor
        return circle
    }()
    
    lazy var letterLabel = UILabel(text: "A")
    lazy var wordLabel = UILabel(text: "Answer 1")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none // из-за этого ячейка и не меняла цвет. Но если изменить, то появится прямоугольная обводка
        backgroundColor = .clear
        cardView.backgroundColor = .white
        setViews()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.cornerRadius = Radius.card
        cardView.layer.masksToBounds = true
    }
    
    func setViews() {
        letterLabel.decorate(color: .answers)
        wordLabel.decorate(color: .answers)
        wordLabel.numberOfLines = 0
    }

    /// Все состояния ячейки в одном месте: раньше три метода красили одни и те же свойства
    /// и затирали друг друга, из-за чего порядок вызова был важен.
    enum State { case normal, selected, eliminated, correct, wrong }

    func apply(_ state: State) {
        switch state {
        case .normal, .eliminated: cardView.backgroundColor = .white
        case .selected:            cardView.backgroundColor = .chosenAns
        case .correct:             cardView.backgroundColor = .correctAns
        case .wrong:               cardView.backgroundColor = .wrongAns
        }

        let isResult = state == .correct || state == .wrong
        let textColor: UIColor = isResult ? .white : .answers
        letterLabel.textColor = textColor
        wordLabel.textColor = textColor

        // Букву оставляем на месте: ряды не переставляем, иначе A/B/C/D поедут и игрок потеряет ориентир.
        // Текст прячем прозрачностью, а не стираем: пустая метка схлопывает высоту строки и ряды прыгают под пальцем.
        wordLabel.alpha = state == .eliminated ? 0 : 1
        cardView.alpha = state == .eliminated ? 0.35 : 1
        isUserInteractionEnabled = state != .eliminated
    }

    func pulseSelected() {
        UIView.animate(withDuration: 1, delay: 0.3 , animations: {
            self.cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }

    func stopPulse() {
        cardView.layer.removeAllAnimations()
        cardView.transform = .identity
    }

    func setConstraints() {
        contentView.addSubview(cardView)
        cardView.addSubview(circleView)
        cardView.addSubview(letterLabel)
        cardView.addSubview(wordLabel)

        circleView.translatesAutoresizingMaskIntoConstraints = false
        letterLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),



            circleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            circleView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 32),
            circleView.heightAnchor.constraint(equalToConstant: 32),

            letterLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            wordLabel.leadingAnchor.constraint(greaterThanOrEqualTo: circleView.trailingAnchor, constant: 12),
            wordLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -10),
            wordLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            wordLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])

        // по умолчанию центрируем по всей карточке, но не наезжаем на circleView
        let centerX = wordLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        centerX.priority = .defaultHigh
        centerX.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    AnswerCell()
}
