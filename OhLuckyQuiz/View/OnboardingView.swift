//
//  OnboardingView.swift
//  OhLuckyQuiz
//

import UIKit

/// Три слайда при первом запуске. Листание — здесь, контроллеру остаётся только выход.
final class OnboardingView: UIView {

    var onFinishTapped: (() -> Void)?
    var onSkipTapped: (() -> Void)?

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    private let slidesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.currentPageIndicatorTintColor = .menuBtns
        control.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.25)
        control.addAction(UIAction { [weak self] _ in
            self?.scroll(to: control.currentPage)
        }, for: .valueChanged)
        return control
    }()

    private lazy var nextButton = UIButton.action(title: localized("Next"), titleColor: .bgCol,
                                                  background: .menuBtns,
                                                  identifier: "onboarding.nextButton")

    /// Та же градиентная кнопка, что в меню.
    private lazy var startButton: UIButton = {
        let btn = GradientButton(type: .system)
        btn.styleAsAction(title: localized("Start Game!"), titleColor: .white,
                          identifier: "onboarding.startButton")
        btn.isHidden = true
        return btn
    }()

    private lazy var skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(localized("Skip"), for: .normal)
        btn.setTitleColor(.bank, for: .normal)
        btn.titleLabel?.font = .montserrat(16)
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.accessibilityIdentifier = "onboarding.skipButton"
        return btn
    }()

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pageControl, nextButton, startButton, skipButton])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: геометрия
    private func setConstraints() {
        addSubview(scrollView)
        addSubview(bottomStack)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        slidesStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(slidesStack)
        scrollView.delegate = self

        let slides = [rulesSlide(), helpSlide(), questionsSlide()]
        slides.forEach { slidesStack.addArrangedSubview($0) }

        let content = makeContentGuide()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -12),

            slidesStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            slidesStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            slidesStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            slidesStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            slidesStack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            slidesStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor,
                                               multiplier: CGFloat(slides.count)),

            bottomStack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    private func setupActions() {
        nextButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            scroll(to: pageControl.currentPage + 1)
        }, for: .touchUpInside)

        startButton.addAction(UIAction { [weak self] _ in
            self?.onFinishTapped?()
        }, for: .touchUpInside)

        skipButton.addAction(UIAction { [weak self] _ in
            self?.onSkipTapped?()
        }, for: .touchUpInside)
    }

    private func scroll(to page: Int) {
        let page = min(max(page, 0), pageControl.numberOfPages - 1)
        scrollView.setContentOffset(CGPoint(x: CGFloat(page) * scrollView.bounds.width, y: 0), animated: true)
        showControls(forPage: page)
    }

    /// На последнем слайде «Далее» уступает место кнопке старта.
    private func showControls(forPage page: Int) {
        pageControl.currentPage = page
        let isLast = page == pageControl.numberOfPages - 1
        nextButton.isHidden = isLast
        startButton.isHidden = !isLast
        skipButton.isHidden = isLast
    }

    //MARK: слайды
    private func rulesSlide() -> UIView {
        let ladder = UIStackView(arrangedSubviews: [
            prizeRow(step: "15", amount: 1_000_000.formattedScore, isTop: true),
            prizeRow(step: "14", amount: 500_000.formattedScore, isTop: false),
            prizeRow(step: "13", amount: 250_000.formattedScore, isTop: false),
            ellipsisRow(),
            prizeRow(step: "1", amount: 100.formattedScore, isTop: false)
        ])
        ladder.axis = .vertical
        ladder.spacing = 8

        let caption = paragraph(localized("Every right answer takes you one step higher. One mistake ends the game."),
                                size: 16)

        let content = UIStackView(arrangedSubviews: [ladder, caption])
        content.axis = .vertical
        content.spacing = 28

        return slide(title: localized("15 questions to a million"), content: content)
    }

    private func helpSlide() -> UIView {
        let fiftyFifty = UILabel(text: "50:50", isBold: true, isLarge: false)
        fiftyFifty.textColor = .bgCol
        let hintPill = UIView()
        hintPill.backgroundColor = .menuBtns
        hintPill.layer.cornerRadius = Radius.pill(40)
        hintPill.addSubview(fiftyFifty)
        fiftyFifty.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hintPill.widthAnchor.constraint(equalToConstant: 84),
            hintPill.heightAnchor.constraint(equalToConstant: 40),
            fiftyFifty.centerXAnchor.constraint(equalTo: hintPill.centerXAnchor),
            fiftyFifty.centerYAnchor.constraint(equalTo: hintPill.centerYAnchor)
        ])

        let content = UIStackView(arrangedSubviews: [
            card(leading: icon("timer"),
                 title: localized("Answer timer"),
                 text: localized("Run out of time and the answer counts as wrong.")),
            card(leading: hintPill,
                 title: localized("One hint"),
                 text: localized("Removes two wrong options. Once per game.")),
            card(leading: icon("checkmark.seal"),
                 title: localized("Safety nets"),
                 text: localized("5 and 10 correct answers lock in your winnings — you keep them even if you lose."))
        ])
        content.axis = .vertical
        content.spacing = 12

        return slide(title: localized("Time is ticking, one hint"), content: content)
    }

    private func questionsSlide() -> UIView {
        var items: [UIView] = [
            card(leading: icon(QuestionSource.online.iconName),
                 title: QuestionSource.online.title,
                 text: QuestionSource.online.explanation),
            card(leading: icon(QuestionSource.offline.iconName),
                 title: QuestionSource.offline.title,
                 text: QuestionSource.offline.explanation),
            footnote(localized("Online and offline questions can be switched in Settings."))
        ]

        // На русском игра в OpenTDB не ходит — упоминать источник незачем
        if AppLanguage.current != .ru { items.append(attribution()) }

        let content = UIStackView(arrangedSubviews: items)
        content.axis = .vertical
        content.spacing = 12
        content.setCustomSpacing(16, after: content.arrangedSubviews[1])
        content.setCustomSpacing(8, after: content.arrangedSubviews[2])

        return slide(title: localized("Where questions come from"), content: content)
    }

    //MARK: кирпичи слайда
    private func slide(title: String, content: UIView) -> UIView {
        let slide = UIView()

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .montserrat(26, bold: true)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, content])
        stack.axis = .vertical
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false
        slide.addSubview(stack)

        let guide = slide.makeContentGuide()

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: slide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: slide.bottomAnchor, constant: -16)
        ])

        return slide
    }

    /// Ступень лестницы призов.
    private func prizeRow(step: String, amount: String, isTop: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = isTop ? .menuBtns : UIColor(white: 1, alpha: 0.09)

        let height: CGFloat = isTop ? 44 : 40
        row.layer.cornerRadius = Radius.pill(height)

        let stepLabel = UILabel()
        stepLabel.text = step
        stepLabel.font = .montserrat(isTop ? 15 : 14, bold: isTop)
        stepLabel.textColor = isTop ? .bgCol : .bank

        let amountLabel = UILabel()
        amountLabel.text = amount
        amountLabel.font = .montserrat(isTop ? 17 : 16, bold: isTop)
        amountLabel.textColor = isTop ? .bgCol : .bank

        let stack = UIStackView(arrangedSubviews: [stepLabel, amountLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(stack)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: height),
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        return row
    }

    /// Пропущенные ступени — тремя точками.
    private func ellipsisRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.alignment = .center
        row.distribution = .equalCentering

        (0..<3).forEach { _ in
            let dot = UIView()
            dot.backgroundColor = UIColor(white: 1, alpha: 0.28)
            dot.layer.cornerRadius = Radius.pill(4)
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4)
            ])
            row.addArrangedSubview(dot)
        }

        let wrapper = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(row)

        NSLayoutConstraint.activate([
            wrapper.heightAnchor.constraint(equalToConstant: 16),
            row.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            row.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor)
        ])

        return wrapper
    }

    /// Карточка слайда: слева иконка или пилюля, справа текст.
    private func card(leading: UIView, title: String, text: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .rectBankView
        card.layer.cornerRadius = Radius.card

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .montserrat(17, bold: true)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let textLabel = paragraph(text, size: 14)

        let texts = UIStackView(arrangedSubviews: [titleLabel, textLabel])
        texts.axis = .vertical
        texts.spacing = 4

        leading.setContentHuggingPriority(.required, for: .horizontal)
        leading.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [leading, texts])
        stack.axis = .horizontal
        stack.spacing = 18
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])

        return card
    }

    private func footnote(_ text: String) -> UIView {
        let label = paragraph(text, size: 13)

        let stack = UIStackView(arrangedSubviews: [icon("info.circle", size: 18), label])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .top

        return stack
    }

    /// Атрибуция источника онлайн-вопросов: название проекта и код лицензии не переводятся.
    private func attribution() -> UILabel {
        let label = paragraph("Online questions: Open Trivia DB · CC BY-SA 4.0", size: 12)
        label.textColor = UIColor(white: 1, alpha: 0.45)
        return label
    }

    private func paragraph(_ text: String, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .montserrat(size)
        label.textColor = .bank
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private func icon(_ name: String, size: CGFloat = 28) -> UIImageView {
        let view = UIImageView(image: UIImage(systemName: name))
        view.tintColor = .menuBtns
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: size),
            view.heightAnchor.constraint(equalToConstant: size)
        ])
        return view
    }
}

extension OnboardingView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        showControls(forPage: Int(round(scrollView.contentOffset.x / scrollView.bounds.width)))
    }
}

#Preview {
    OnboardingView()
}
