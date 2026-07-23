//
//  StatisticsView.swift
//  ohLucky_Ivashin_2
//

import UIKit

final class StatisticsView: UIView {

    var onBackTapped: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Back", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.layer.cornerRadius = 12
        return btn
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setupScroll()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }

    func render(_ stats: QuizStats) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let backRow = UIStackView(arrangedSubviews: [backButton, UIView()])
        backRow.axis = .horizontal
        contentStack.addArrangedSubview(backRow)
        contentStack.setCustomSpacing(20, after: backRow)

        let title = sectionTitle("My Statistics", size: 26)
        contentStack.addArrangedSubview(title)
        contentStack.setCustomSpacing(20, after: title)

        let tilesRow = UIStackView(arrangedSubviews: [
            tile(number: "\(stats.gamesPlayed)", caption: "games played", style: .yellow),
            tile(number: "\(stats.totalCorrect)", caption: "correct answers", style: .yellow)
        ])
        tilesRow.axis = .horizontal
        tilesRow.spacing = 14
        tilesRow.distribution = .fillEqually
        contentStack.addArrangedSubview(tilesRow)

        let accuracyTile = tile(number: "\(stats.overallAccuracyPercent)%", caption: "accuracy", style: .purple)
        contentStack.addArrangedSubview(accuracyTile)
        contentStack.setCustomSpacing(20, after: accuracyTile)

        contentStack.addArrangedSubview(summaryRow(title: "Total questions", value: "\(stats.totalAnswered)"))
        contentStack.addArrangedSubview(summaryRow(title: "Total winnings", value: "0"))
        let lastSummary = summaryRow(title: "Avg. answer time", value: "—")
        contentStack.addArrangedSubview(lastSummary)
        contentStack.setCustomSpacing(24, after: lastSummary)

        let categoriesHeader = sectionTitle("By category", size: 17)
        contentStack.addArrangedSubview(categoriesHeader)
        contentStack.setCustomSpacing(12, after: categoriesHeader)

        for category in QuizCategory.allCases {
            contentStack.addArrangedSubview(
                categoryRow(name: category.displayName, percent: stats.accuracyPercent(for: category))
            )
        }
    }

    // MARK: - Building blocks

    private enum TileStyle { case yellow, purple }

    private func tile(number: String, caption: String, style: TileStyle) -> UIView {
        let card: UIView
        switch style {
        case .yellow:
            card = UIView()
            card.backgroundColor = UIColor(named: "menuBtns")
        case .purple:
            card = GradientView()
        }
        card.layer.cornerRadius = 22
        card.layer.masksToBounds = true

        let numberColor: UIColor = style == .yellow ? .black : .white
        let captionColor: UIColor = style == .yellow ? .darkGray : UIColor(white: 1, alpha: 0.85)

        let numberLabel = label(number, size: 28, color: numberColor, align: .center)
        let captionLabel = label(caption, size: 12, color: captionColor, align: .center)

        let stack = UIStackView(arrangedSubviews: [numberLabel, captionLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        pin(stack, in: card, insetsV: 20, insetsH: 14)
        return card
    }

    private func summaryRow(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20

        let titleLabel = label(title, size: 14, color: .bgCol, align: .left)
        let valueLabel = label(value, size: 19, color: .bgCol, align: .right)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        pin(stack, in: card, insetsV: 16, insetsH: 20)
        return card
    }

    private func categoryRow(name: String, percent: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16

        let nameLabel = label(name, size: 13, color: .bgCol, align: .left)
        let percentLabel = label("\(percent)%", size: 13, color: .bgCol, align: .right)
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        let header = UIStackView(arrangedSubviews: [nameLabel, percentLabel])
        header.axis = .horizontal
        header.alignment = .center

        let track = UIView()
        track.backgroundColor = UIColor(named: "bankColor")
        track.layer.cornerRadius = 4
        track.translatesAutoresizingMaskIntoConstraints = false
        track.heightAnchor.constraint(equalToConstant: 8).isActive = true

        let fillWidth = CGFloat(max(0, min(percent, 100))) / 100.0
        if fillWidth > 0 {
            let fill = UIView()
            fill.backgroundColor = UIColor(named: "menuBtns")
            fill.layer.cornerRadius = 4
            fill.translatesAutoresizingMaskIntoConstraints = false
            track.addSubview(fill)
            NSLayoutConstraint.activate([
                fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
                fill.topAnchor.constraint(equalTo: track.topAnchor),
                fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: fillWidth)
            ])
        }

        let stack = UIStackView(arrangedSubviews: [header, track])
        stack.axis = .vertical
        stack.spacing = 6
        pin(stack, in: card, insetsV: 12, insetsH: 16)
        return card
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String, size: CGFloat) -> UILabel {
        label(text, size: size, color: .white, align: .left)
    }

    private func label(_ text: String, size: CGFloat, color: UIColor, align: NSTextAlignment) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont(name: "Montserrat-Regular", size: size)
        l.textColor = color
        l.textAlignment = align
        l.numberOfLines = 0
        return l
    }

    private func pin(_ inner: UIView, in card: UIView, insetsV: CGFloat, insetsH: CGFloat) {
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: insetsV),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -insetsV),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: insetsH),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -insetsH)
        ])
    }

    private func setupScroll() {
        scrollView.showsVerticalScrollIndicator = false
        contentStack.axis = .vertical
        contentStack.spacing = 12

        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)
    }
}

private final class GradientView: UIView {
    private let gradient = UIColor.makeGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradient, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
