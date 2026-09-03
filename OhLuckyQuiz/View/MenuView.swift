//
//  MenuView.swift
//  OhLuckyQuiz
//
//  Created by Ivashin Ivan on 19.10.2025.
//

import UIKit

class MenuView: UIView {

    lazy var logoView: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "logo")
        logo.contentMode = .scaleAspectFit
        return logo
    }()

    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Oh Lucky"
        lbl.font = .montserrat(32, bold: true)
        lbl.textColor = .white
        return lbl
    }()

    lazy var vStack: UIStackView = {
        let vs = UIStackView(arrangedSubviews: [])
        vs.axis = .vertical
        vs.spacing = 12
        vs.alignment = .fill
        return vs
    }()

    lazy var startButton: UIButton = {
        let btn = GradientButton(type: .system)
        btn.styleAsAction(title: localized("Start Game!"), titleColor: .white,
                          identifier: "menu.startButton")
        return btn
    }()

    lazy var settingsButton = UIButton.action(title: localized("Settings"), titleColor: .black,
                                              background: .menuBtns, isBold: false,
                                              identifier: "menu.settingsButton")

    lazy var statisticButton = UIButton.action(title: localized("My Statistics"), titleColor: .black,
                                               background: .menuBtns, isBold: false,
                                               identifier: "menu.statisticButton")

    /// Логотип в шапке меню — конечное положение.
    private var logoTopConstraint: NSLayoutConstraint!
    /// Логотип по центру экрана — совпадает с launch screen.
    private var logoCenterYConstraint: NSLayoutConstraint!

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setConstraints()
    }

    //MARK: геометрия
    func setConstraints() {
        self.addSubview(logoView)
        self.addSubview(titleLabel)
        self.addSubview(vStack)

        logoView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(startButton)
        vStack.addArrangedSubview(settingsButton)
        vStack.addArrangedSubview(statisticButton)


        let content = makeContentGuide()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])

        logoTopConstraint = logoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 9)
        logoCenterYConstraint = logoView.centerYAnchor.constraint(equalTo: centerYAnchor)

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            logoTopConstraint,
            logoView.widthAnchor.constraint(equalToConstant: 195),
            logoView.heightAnchor.constraint(equalToConstant: 195)
        ])

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 56),
            vStack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: content.trailingAnchor),
        ])
    }

    /// Подписи обновляются после смены языка — меню живёт под настройками и не пересоздаётся
    func applyLocalization() {
        startButton.setTitle(localized("Start Game!"), for: .normal)
        settingsButton.setTitle(localized("Settings"), for: .normal)
        statisticButton.setTitle(localized("My Statistics"), for: .normal)
    }

    //MARK: заставка
    /// Стартовая раскладка повторяет launch screen: логотип по центру, меню скрыто.
    func prepareIntro() {
        logoTopConstraint.isActive = false
        logoCenterYConstraint.isActive = true
        titleLabel.alpha = 0
        vStack.alpha = 0
    }

    /// Логотип уезжает в шапку, следом проявляется меню.
    func playIntro() {
        logoCenterYConstraint.isActive = false
        logoTopConstraint.isActive = true

        guard !UIAccessibility.isReduceMotionEnabled else {
            layoutIfNeeded()
            titleLabel.alpha = 1
            vStack.alpha = 1
            return
        }

        UIView.animate(withDuration: 0.7, delay: 0.25, usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
            self.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.4, delay: 0.65) {
            self.titleLabel.alpha = 1
            self.vStack.alpha = 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

#Preview {
    MenuView()
}

/// Кнопка с градиентным фоном: сам градиент — переиспользуемая GradientView позади контента.
final class GradientButton: UIButton {

    private let gradientBackground = GradientView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientBackground.isUserInteractionEnabled = false
        gradientBackground.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(gradientBackground, at: 0)

        NSLayoutConstraint.activate([
            gradientBackground.topAnchor.constraint(equalTo: topAnchor),
            gradientBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBackground.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBackground.layer.cornerRadius = layer.cornerRadius
    }
}
