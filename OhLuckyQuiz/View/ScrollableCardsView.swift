//
//  ScrollableCardsView.swift
//  OhLuckyQuiz
//

import UIKit

/// Экран-список белых карточек на прокрутке: статистика и достижения.
/// Наследник добавляет свои карточки в `contentStack` и строит их из `label` и `pin`.
class ScrollableCardsView: UIView {

    var onBackTapped: (() -> Void)?

    let contentStack = UIStackView()
    private let scrollView = UIScrollView()
    lazy var backButton = UIButton.backPill(identifier: backButtonIdentifier)

    /// Наследник задаёт свой идентификатор для UI-тестов.
    var backButtonIdentifier: String { "" }

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setupScroll()
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Очищает стек и ставит первым рядом кнопку «Назад» — с этого начинается render обоих экранов.
    func resetContent() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let backRow = UIStackView(arrangedSubviews: [backButton, UIView()])
        backRow.axis = .horizontal
        contentStack.addArrangedSubview(backRow)
        contentStack.setCustomSpacing(20, after: backRow)
    }

    func label(_ text: String, size: CGFloat, color: UIColor, align: NSTextAlignment) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .montserrat(size)
        l.textColor = color
        l.textAlignment = align
        l.numberOfLines = 0
        return l
    }

    func pin(_ inner: UIView, in card: UIView, insetsV: CGFloat, insetsH: CGFloat) {
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: insetsV),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -insetsV),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: insetsH),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -insetsH)
        ])
    }

    /// Отступ колонки читается из неё в layoutSubviews — тот же расчёт, что и у остальных экранов,
    /// а не отдельная копия формулы. Сама guide в констрейнтах контента не участвует: contentStack
    /// пришлось бы пинить к frameLayoutGuide, иначе scrollView перестаёт запрещать горизонтальный скролл.
    private var contentGuide: UILayoutGuide!

    private func setupScroll() {
        scrollView.showsVerticalScrollIndicator = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.isLayoutMarginsRelativeArrangement = true // отступы задают ширину колонки

        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentGuide = makeContentGuide(inset: 24)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = contentGuide.layoutFrame.minX
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: side, bottom: 0, trailing: side)
    }
}

/// Переключатель из двух-трёх взаимоисключающих вариантов: белая пилюля,
/// активный сегмент залит жёлтым. Разделы статистики и выбор языка в настройках.
final class SegmentedTabs: UIView {

    var onSelect: ((Int) -> Void)?

    private let titles: [String]
    private let identifiers: [String]
    private var selected: Int
    private let stack = UIStackView()

    init(titles: [String], identifiers: [String], selected: Int = 0) {
        self.titles = titles
        self.identifiers = identifiers
        self.selected = selected
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = Radius.pill(48)
        heightAnchor.constraint(equalToConstant: 48).isActive = true

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])

        rebuild()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func rebuild() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, title) in titles.enumerated() {
            let isOn = index == selected

            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(isOn ? .bgCol : .systemGray, for: .normal)
            btn.titleLabel?.font = .montserrat(17, bold: isOn)
            btn.backgroundColor = isOn ? .menuBtns : .clear
            btn.layer.cornerRadius = Radius.pill(40)
            btn.accessibilityIdentifier = identifiers.indices.contains(index) ? identifiers[index] : nil

            btn.addAction(UIAction { [weak self] _ in
                guard let self, index != selected else { return }
                selected = index
                rebuild()
                onSelect?(index)
            }, for: .touchUpInside)

            stack.addArrangedSubview(btn)
        }
    }
}
