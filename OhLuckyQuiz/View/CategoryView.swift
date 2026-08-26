//
//  CategoryView.swift
//  OhLuckyQuiz
//

import UIKit

class CategoryView: UIView {

    lazy var titleLabel = UILabel(text: localized("Choose a category"), isBold: false, isLarge: true)
    lazy var categoriesTableView = UITableView()

    lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(localized("Back"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.layer.cornerRadius = 12
        btn.accessibilityIdentifier = "category.backButton"

        return btn
    }()

    var onBackTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setViews()
        setConstraints()
        setupActions()
    }

    func setViews() {
        titleLabel.textColor = .white

        categoriesTableView.accessibilityIdentifier = "category.tableView"
        categoriesTableView.backgroundColor = .clear
        categoriesTableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusedID)
        categoriesTableView.rowHeight = UITableView.automaticDimension
        categoriesTableView.estimatedRowHeight = 48
        categoriesTableView.separatorStyle = .none
        categoriesTableView.showsVerticalScrollIndicator = false
    }

    func setConstraints() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(categoriesTableView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false

        let content = makeContentGuide()

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoriesTableView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    CategoryView()
}
