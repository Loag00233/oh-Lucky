//
//  ResultView.swift
//  ohLucky_Ivashin_2
//

import UIKit

class ResultView: UIView {

    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = String(localized: "Game over!")
        lbl.font = UIFont(name: "Montserrat-Bold", size: 32)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    lazy var scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Montserrat-Bold", size: 20)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    lazy var menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(String(localized: "Back to menu"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 250).isActive = true
        btn.layer.cornerRadius = 23
        return btn
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

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80),

            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),

            menuButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            menuButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -56),
        ])
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
