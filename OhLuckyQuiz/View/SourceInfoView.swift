//
//  SourceInfoView.swift
//  OhLuckyQuiz
//

import UIKit

/// Карточка с объяснением, откуда берутся вопросы, поверх затемнённого экрана категорий.
final class SourceInfoView: UIView {

    var onCloseTapped: (() -> Void)?

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Radius.card
        return view
    }()

    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(localized("Got it"), for: .normal)
        btn.setTitleColor(.bgCol, for: .normal)
        btn.titleLabel?.font = .montserrat(17, bold: true)
        btn.backgroundColor = .menuBtns
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        btn.layer.cornerRadius = Radius.pill(56)
        btn.accessibilityIdentifier = "sourceInfo.closeButton"
        return btn
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        setConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: геометрия
    private func setConstraints() {
        addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = localized("Where questions come from")
        titleLabel.font = .montserrat(18, bold: true)
        titleLabel.textColor = .bgCol
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0, alpha: 0.1)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel,
                                                   section(.online),
                                                   section(.offline),
                                                   separator,
                                                   footnote(),
                                                   closeButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(18, after: titleLabel)
        stack.setCustomSpacing(20, after: stack.arrangedSubviews[4])
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        let content = makeContentGuide()

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        closeButton.addAction(UIAction { [weak self] _ in
            self?.onCloseTapped?()
        }, for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        addGestureRecognizer(tap)
    }

    @objc private func backgroundTapped(_ recognizer: UITapGestureRecognizer) {
        guard !card.frame.contains(recognizer.location(in: self)) else { return }
        onCloseTapped?()
    }

    //MARK: содержимое карточки
    private func section(_ source: QuestionSource) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = source.title
        titleLabel.font = .montserrat(15, bold: true)
        titleLabel.textColor = .bgCol

        let textLabel = UILabel()
        textLabel.text = source.explanation
        textLabel.font = .montserrat(14)
        textLabel.textColor = .answers
        textLabel.numberOfLines = 0
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let texts = UIStackView(arrangedSubviews: [titleLabel, textLabel])
        texts.axis = .vertical
        texts.spacing = 3

        let icon = symbol(source.iconName)

        let stack = UIStackView(arrangedSubviews: [icon, texts])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top

        return stack
    }

    private func footnote() -> UILabel {
        let label = UILabel()
        label.text = localized("Online and offline questions can be switched in Settings.")
        label.font = .montserrat(13)
        label.textColor = .answers
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private func symbol(_ name: String) -> UIImageView {
        let view = UIImageView(image: UIImage(systemName: name))
        view.tintColor = .bgCol
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 22),
            view.heightAnchor.constraint(equalToConstant: 22)
        ])
        return view
    }
}

#Preview {
    SourceInfoView()
}
