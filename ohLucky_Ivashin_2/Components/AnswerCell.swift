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
        letterLabel.regularDecoration()
        wordLabel.regularDecoration()
    }

    func updateColorOfSelectedCell(_ isSelected: Bool) {
        cardView.backgroundColor = isSelected ? .gradientEnd : .white
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

            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),



            circleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            circleView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 32),
            circleView.heightAnchor.constraint(equalToConstant: 32),
            
            letterLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            wordLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    AnswerCell()
}
