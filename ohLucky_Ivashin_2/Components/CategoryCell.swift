//
//  CategoryCell.swift
//  ohLucky_Ivashin_2
//

import UIKit

class CategoryCell: UITableViewCell {

    static let reusedID = "CategoryCell"

    lazy var cardView = UIView()
    lazy var nameLabel = UILabel(text: "Category", isBold: false, isLarge: true)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        cardView.backgroundColor = .white
        setConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
    }

    func setConstraints() {
        contentView.addSubview(cardView)
        cardView.addSubview(nameLabel)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),

            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    CategoryCell()
}
