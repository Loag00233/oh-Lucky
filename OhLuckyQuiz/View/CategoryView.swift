//
//  CategoryView.swift
//  OhLuckyQuiz
//

import UIKit

class CategoryView: UIView {

    lazy var titleLabel = UILabel(text: localized("Choose a category"), isBold: false, isLarge: true)
    lazy var categoriesTableView = UITableView()

    lazy var backButton = UIButton.backPill(identifier: "category.backButton")

    lazy var sourceBadge = makeSourceBadge()

    var onBackTapped: (() -> Void)?
    var onSourceInfoTapped: (() -> Void)?

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
        addSubview(sourceBadge)
        addSubview(categoriesTableView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceBadge.translatesAutoresizingMaskIntoConstraints = false
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false

        let content = makeContentGuide()

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            sourceBadge.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            sourceBadge.centerXAnchor.constraint(equalTo: centerXAnchor),
            sourceBadge.leadingAnchor.constraint(greaterThanOrEqualTo: content.leadingAnchor),
            sourceBadge.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor),

            categoriesTableView.topAnchor.constraint(equalTo: sourceBadge.bottomAnchor, constant: 20),
            categoriesTableView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)

        sourceBadge.addAction(UIAction { [weak self] _ in
            self?.onSourceInfoTapped?()
        }, for: .touchUpInside)
    }

    /// Пилюля с режимом вопросов: значок режима, подпись и «i» — знак, что по ней можно нажать.
    private func makeSourceBadge() -> UIControl {
        let source = QuestionSource.current

        let badge = UIControl()
        badge.backgroundColor = .rectBankView
        badge.layer.cornerRadius = Radius.pill(32)
        badge.accessibilityIdentifier = "category.sourceBadge"
        badge.isAccessibilityElement = true
        badge.accessibilityTraits = .button
        badge.accessibilityLabel = "\(source.title) · \(source.badgeDetail)"

        let titleLabel = UILabel()
        titleLabel.text = source.title
        titleLabel.font = .montserrat(13, bold: true)
        titleLabel.textColor = .white

        let detailLabel = UILabel()
        detailLabel.text = "· " + source.badgeDetail
        detailLabel.font = .montserrat(13)
        detailLabel.textColor = .bank
        detailLabel.lineBreakMode = .byTruncatingTail
        detailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [symbol(source.iconName, tint: .menuBtns, size: 16),
                                                   titleLabel,
                                                   detailLabel,
                                                   symbol("info.circle", tint: .bank, size: 15)])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(stack)

        NSLayoutConstraint.activate([
            badge.heightAnchor.constraint(equalToConstant: 32),
            stack.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])

        return badge
    }

    private func symbol(_ name: String, tint: UIColor, size: CGFloat) -> UIImageView {
        let view = UIImageView(image: UIImage(systemName: name))
        view.tintColor = tint
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: size),
            view.heightAnchor.constraint(equalToConstant: size)
        ])
        return view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    CategoryView()
}
