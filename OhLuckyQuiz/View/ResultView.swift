//
//  ResultView.swift
//  OhLuckyQuiz
//

import UIKit

class ResultView: UIView {

    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = localized("Game over!")
        lbl.font = .montserrat(32, bold: true)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    lazy var scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .montserrat(20, bold: true)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    lazy var menuButton = UIButton.action(title: localized("Back to menu"), titleColor: .white,
                                          background: .exitBtnC, width: 250,
                                          identifier: "result.menuButton")

    /// Тост о новом достижении: без него ачивки открываются молча и половина игроков
    /// про отдельный экран так и не узнает.
    private lazy var toastLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .montserrat(15, bold: true)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    lazy var achievementToast: UIView = {
        let view = UIView()
        view.backgroundColor = .menuBtns
        view.layer.cornerRadius = Radius.card
        view.alpha = 0
        view.accessibilityIdentifier = "result.achievementToast"

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            toastLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])

        return view
    }()

    var onMenuTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setConstraints()
        setupActions()
    }

    func setConstraints() {
        addSubview(titleLabel)
        addSubview(scoreLabel)
        addSubview(menuButton)
        addSubview(achievementToast)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        achievementToast.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80),

            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),

            achievementToast.centerXAnchor.constraint(equalTo: centerXAnchor),
            achievementToast.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 28),
            achievementToast.widthAnchor.constraint(lessThanOrEqualToConstant: 300),

            menuButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            menuButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -56),
        ])
    }

    func showAchievementToast(_ text: String) {
        toastLabel.text = text
        UIView.animate(withDuration: 0.4, delay: 0.5) { self.achievementToast.alpha = 1 }
    }

    func setupActions() {
        menuButton.addAction(UIAction { [weak self] _ in
            self?.onMenuTapped?()
        }, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    ResultView()
}
