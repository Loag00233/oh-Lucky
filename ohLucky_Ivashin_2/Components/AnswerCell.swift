//
//  AnswerCell.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 04.11.2025.
//

import UIKit

class AnswerCell: UITableViewCell {
    
    static let reusedID = "WordCell"

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
        layoutSubviews()
        setViews()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
    }
    
    func setViews() {
        letterLabel.regularDecoration()
        wordLabel.regularDecoration()
    }
    
    func setConstraints() {
        contentView.addSubview(circleView)
        contentView.addSubview(letterLabel)
        contentView.addSubview(wordLabel)
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        letterLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 32),
            circleView.heightAnchor.constraint(equalToConstant: 32),
            
            letterLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            wordLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    AnswerCell()
}
