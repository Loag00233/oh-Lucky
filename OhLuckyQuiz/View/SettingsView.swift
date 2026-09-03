//
//  SettingsView.swift
//  OhLuckyQuiz
//

import UIKit

final class SettingsView: UIView {

    var onBackTapped: (() -> Void)?
    var onLanguageSelected: ((AppLanguage) -> Void)?
    var onSoundToggled: ((Bool) -> Void)?
    var onHapticsToggled: ((Bool) -> Void)?
    var onOfflineToggled: ((Bool) -> Void)?
    var onPrivacyTapped: (() -> Void)?
    var onSupportTapped: (() -> Void)?
    var onTermsOfServiceTapped: (() -> Void)?
    var onResetStatsTapped: (() -> Void)?
    var onHowToPlayTapped: (() -> Void)?

    lazy var backButton = UIButton.backPill(identifier: "settings.backButton")

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .montserrat(26, bold: true)
        lbl.textColor = .white
        return lbl
    }()

    private lazy var languageHeader: UILabel = {
        let lbl = UILabel()
        lbl.font = .montserrat(16)
        lbl.textColor = .white
        return lbl
    }()

    private lazy var languageControl: SegmentedTabs = {
        let control = SegmentedTabs(titles: AppLanguage.allCases.map(\.displayName),
                                    identifiers: AppLanguage.allCases.map { "settings.language.\($0.rawValue)" },
                                    selected: AppLanguage.allCases.firstIndex(of: AppLanguage.current) ?? 0)
        control.onSelect = { [weak self] index in
            self?.onLanguageSelected?(AppLanguage.allCases[index])
        }
        return control
    }()

    private lazy var togglesHeader: UILabel = {
        let lbl = UILabel()
        lbl.font = .montserrat(16)
        lbl.textColor = .white
        return lbl
    }()

    lazy var soundSwitch = makeSwitch(identifier: "settings.soundSwitch", isOn: AppSettings.soundEnabled)
    lazy var hapticsSwitch = makeSwitch(identifier: "settings.hapticsSwitch", isOn: AppSettings.hapticsEnabled)
    lazy var offlineSwitch = makeSwitch(identifier: "settings.offlineSwitch", isOn: AppSettings.playOfflineEnabled)

    private lazy var offlineTitleLabel = rowTitle()
    private lazy var howToPlayTitleLabel = rowTitle()
    lazy var howToPlayRow = makeHowToPlayRow()

    private lazy var soundTitleLabel = rowTitle()
    private lazy var hapticsTitleLabel = rowTitle()

    lazy var privacyButton = makeLinkButton(identifier: "settings.privacyButton")
    lazy var termsofServiceButton = makeLinkButton(identifier: "settings.termsOfServiceButton")
    lazy var supportButton = makeLinkButton(identifier: "settings.supportButton")

    /// Атрибуция источника онлайн-вопросов: название проекта и код лицензии не переводятся.
    private lazy var attributionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Online questions: Open Trivia DB · CC BY-SA 4.0"
        lbl.font = .montserrat(13)
        lbl.textColor = UIColor(white: 1, alpha: 0.6)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.accessibilityIdentifier = "settings.attributionLabel"
        return lbl
    }()
    


    lazy var resetStatsButton: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .montserrat(16)
            btn.backgroundColor = .exitBtnC
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.layer.cornerRadius = Radius.pill(48)
            btn.accessibilityIdentifier = "settings.resetStatsButton"
            return btn
        }()

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()

    private let contentView = UIView()

    // Служебные ссылки
    private lazy var linksRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [privacyButton, termsofServiceButton, supportButton, attributionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private lazy var togglesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            toggleRow(soundTitleLabel, soundSwitch),
            toggleRow(hapticsTitleLabel, hapticsSwitch),
            toggleRow(offlineTitleLabel, offlineSwitch)
        ]
        )
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setConstraints()
        setupActions()
        applyLocalization()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Вызывается и при сборке экрана, и после смены языка
    func applyLocalization() {
        backButton.setTitle(localized("Back"), for: .normal)
        titleLabel.text = localized("Settings")
        languageHeader.text = localized("Language")
        togglesHeader.text = localized("Sound and vibration")
        soundTitleLabel.text = localized("Sound")
        hapticsTitleLabel.text = localized("Vibration")
        offlineTitleLabel.text = localized("Play Offline")
        privacyButton.setTitle(localized("Privacy policy"), for: .normal)
        termsofServiceButton.setTitle(localized("Terms of Service"), for: .normal)
        supportButton.setTitle(localized("Support"), for: .normal)
        resetStatsButton.setTitle(localized("Reset statistics"), for: .normal)
        howToPlayTitleLabel.text = localized("How to play")
        howToPlayRow.accessibilityLabel = localized("How to play")
        togglesStack.arrangedSubviews.last?.isHidden = AppLanguage.current == .ru
        attributionLabel.isHidden = AppLanguage.current == .ru
    }

    //MARK: геометрия
    private func setConstraints() {
        // содержимое переросло экран SE — без прокрутки нижняя кнопка обрезается
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        [backButton, titleLabel, languageHeader, languageControl, howToPlayRow, togglesHeader, togglesStack,
         resetStatsButton, linksRow].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let content = contentView.makeContentGuide()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            languageHeader.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            languageHeader.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            languageControl.topAnchor.constraint(equalTo: languageHeader.bottomAnchor, constant: 12),
            languageControl.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            languageControl.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            howToPlayRow.topAnchor.constraint(equalTo: languageControl.bottomAnchor, constant: 12),
            howToPlayRow.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            howToPlayRow.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            togglesHeader.topAnchor.constraint(equalTo: howToPlayRow.bottomAnchor, constant: 28),
            togglesHeader.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            togglesStack.topAnchor.constraint(equalTo: togglesHeader.bottomAnchor, constant: 12),
            togglesStack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            togglesStack.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            resetStatsButton.topAnchor.constraint(equalTo: togglesStack.bottomAnchor, constant: 28),
            resetStatsButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            resetStatsButton.trailingAnchor.constraint(equalTo: content.trailingAnchor),

            linksRow.topAnchor.constraint(equalTo: resetStatsButton.bottomAnchor, constant: 24),
            linksRow.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            linksRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)

        soundSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onSoundToggled?(soundSwitch.isOn)
        }, for: .valueChanged)

        hapticsSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onHapticsToggled?(hapticsSwitch.isOn)
        }, for: .valueChanged)
        
        offlineSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onOfflineToggled?(offlineSwitch.isOn)
        }, for: .valueChanged)

        privacyButton.addAction(UIAction { [weak self] _ in
            self?.onPrivacyTapped?()
        }, for: .touchUpInside)
        
        termsofServiceButton.addAction(UIAction { [weak self] _ in
            self?.onTermsOfServiceTapped?()
        }, for: .touchUpInside)

        supportButton.addAction(UIAction { [weak self] _ in
            self?.onSupportTapped?()
        }, for: .touchUpInside)

        resetStatsButton.addAction(UIAction { [weak self] _ in
            self?.onResetStatsTapped?()
        }, for: .touchUpInside)

        howToPlayRow.addAction(UIAction { [weak self] _ in
            self?.onHowToPlayTapped?()
        }, for: .touchUpInside)
    }

    /// Строка возврата к онбордингу - той же карточкой, что ряды звука и вибрации
    private func makeHowToPlayRow() -> UIControl {
        let row = UIControl()
        row.backgroundColor = .white
        row.layer.cornerRadius = Radius.card
        row.accessibilityIdentifier = "settings.howToPlayButton"
        row.isAccessibilityElement = true
        row.accessibilityTraits = .button
        row.accessibilityLabel = localized("How to play")

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [howToPlayTitleLabel, chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -20)
        ])

        return row
    }

    private func makeLinkButton(identifier: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .normal)
        btn.titleLabel?.font = .montserrat(13)
        btn.titleLabel?.numberOfLines = 0
        btn.accessibilityIdentifier = identifier
        return btn
    }

    //MARK: звук и вибрация
    private func makeSwitch(identifier: String, isOn: Bool) -> UISwitch {
        let control = UISwitch()
        control.isOn = isOn
        control.onTintColor = .menuBtns
        control.accessibilityIdentifier = identifier
        return control
    }

    private func rowTitle() -> UILabel {
        let lbl = UILabel()
        lbl.font = .montserrat(14)
        lbl.textColor = .bgCol
        lbl.numberOfLines = 0
        return lbl
    }

    /// Белая карточка с подписью слева и контролом справа — раскладка строк из статистики.
    private func toggleRow(_ title: UILabel, _ control: UISwitch) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = Radius.card

        control.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [title, control])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])

        return card
    }

}
