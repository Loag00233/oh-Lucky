//
//  SettingsView.swift
//  ohLucky_Ivashin_2
//

import UIKit

final class SettingsView: UIView {

    var onBackTapped: (() -> Void)?
    var onLanguageSelected: ((AppLanguage) -> Void)?

    lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.layer.cornerRadius = 12
        btn.accessibilityIdentifier = "settings.backButton"
        return btn
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Montserrat-Bold", size: 26)
        lbl.textColor = .white
        return lbl
    }()

    private lazy var languageHeader: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Montserrat-Regular", size: 16)
        lbl.textColor = .white
        return lbl
    }()

    private lazy var optionsStack: UIStackView = {
        let stack = UIStackView()
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
        rebuildLanguageOptions()
    }

    //MARK: геометрия
    private func setConstraints() {
        [backButton, titleLabel, languageHeader, optionsStack].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let content = makeContentGuide()

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            languageHeader.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            languageHeader.leadingAnchor.constraint(equalTo: content.leadingAnchor),

            optionsStack.topAnchor.constraint(equalTo: languageHeader.bottomAnchor, constant: 12),
            optionsStack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            optionsStack.trailingAnchor.constraint(equalTo: content.trailingAnchor)
        ])
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)
    }

    //MARK: выбор языка
    private func rebuildLanguageOptions() {
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        AppLanguage.allCases.forEach { optionsStack.addArrangedSubview(languageRow($0)) }
    }

    private func languageRow(_ language: AppLanguage) -> UIButton {
        let isSelected = language == AppLanguage.current

        let btn = UIButton(type: .system)
        btn.setTitle(language.displayName, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: isSelected ? "Montserrat-Bold" : "Montserrat", size: 20)
        btn.backgroundColor = isSelected ? .menuBtns : .white
        btn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        btn.layer.cornerRadius = 23
        btn.accessibilityIdentifier = "settings.language.\(language.rawValue)"

        btn.addAction(UIAction { [weak self] _ in
            self?.onLanguageSelected?(language)
        }, for: .touchUpInside)

        return btn
    }
}
