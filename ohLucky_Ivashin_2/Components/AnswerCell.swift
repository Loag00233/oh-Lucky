//
//  AnswerCell.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 04.11.2025.
//

import UIKit

class AnswerCell: UITableViewCell {
    
    static let reusedID = "WordCell"

    lazy var cardView = UIView() // на нее все кладем, чтобы ячейки могли "разлепиться" друг от друга

    lazy var circleView: UIImageView = {
        let circle = UIImageView()
        circle.image = UIImage(named: "EllipseAnswer")
        circle.contentMode = .scaleAspectFit
        circle.layer.cornerRadius = 16
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor(named: "bankColor")?.cgColor
        return circle
    }()
    
    lazy var letterLabel = UILabel(text: "A")
    lazy var wordLabel = UILabel(text: "Вариант 1")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none // из-за этого ячейка и не меняла цвет. Но если изменить, то появится прямоугольная обводка
        backgroundColor = .clear
        cardView.backgroundColor = .white
        layoutSubviews()
        setViews()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
    }
    
    func setViews() {
        letterLabel.regularAnswersDecoration()
        wordLabel.regularAnswersDecoration()
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
    }

    func updateColorOfSelectedCell(_ isSelected: Bool) {
        cardView.backgroundColor = isSelected ? .chosenAns : .white
        letterLabel.textColor = UIColor(named: "answersColor")
        wordLabel.textColor = UIColor(named: "answersColor")
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

    func updateColorForResult(_ isCorrect: Bool) {
        cardView.backgroundColor = isCorrect ? .correctAns : .wrongAns
        letterLabel.textColor = .white
        wordLabel.textColor = .white
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
