//
//  MenuView.swift
//  ohLucky_Ivashin_2
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
        lbl.text = "Oh, Lucky"
        lbl.font = UIFont(name: "Montserrat-Bold", size: 32)
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
        let btn = UIButton(type: .system)
        btn.setTitle(String(localized: "Start Game!"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        btn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 314).isActive = true
        btn.layer.cornerRadius = 23

        // Добавляем градиент
        let gradient = UIColor.makeGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 314, height: 63)
        gradient.cornerRadius = 23
        btn.layer.insertSublayer(gradient, at: 0)
        btn.accessibilityIdentifier = "menu.startButton"

        return btn
    }()

    lazy var settingsButton: UIButton = {
        let setBtn = UIButton(type: .system)
        setBtn.setTitle(String(localized: "Settings"), for: .normal)
        setBtn.setTitleColor(.black, for: .normal)
        setBtn.titleLabel?.font = UIFont(name: "Montserrat", size: 20)
        setBtn.backgroundColor = .menuBtns
        setBtn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        setBtn.layer.cornerRadius = 23
        setBtn.accessibilityIdentifier = "menu.settingsButton"

        return setBtn
    }()

    lazy var statisticButton: UIButton = {
        let statBtn = UIButton(type: .system)
        statBtn.setTitle(String(localized: "My Statistics"), for: .normal)
        statBtn.setTitleColor(.black, for: .normal)
        statBtn.titleLabel?.font = UIFont(name: "Montserrat", size: 20)
        statBtn.backgroundColor = .menuBtns
        statBtn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        statBtn.layer.cornerRadius = 23
        statBtn.accessibilityIdentifier = "menu.statisticButton"

        return statBtn
    }()


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
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44),
        ])
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
