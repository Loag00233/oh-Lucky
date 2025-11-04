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
        let startB = UIButton(type: .system)
        startB.setTitle("Начать игру!", for: .normal)
        startB.setTitleColor(.white, for: .normal)
        startB.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)

        startB.heightAnchor.constraint(equalToConstant: 63).isActive = true
        startB.widthAnchor.constraint(equalToConstant: 334).isActive = true
        startB.layer.cornerRadius = 23

        let gradient = UIColor.makeGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 334, height: 63)
        startB.layer.insertSublayer(gradient, at: 0)
        gradient.cornerRadius = 23

        return startB
    }()

    lazy var settingsButton: UIButton = {
        let setBtn = UIButton(type: .system)
        setBtn.setTitle("Настройки", for: .normal)
        setBtn.setTitleColor(.black, for: .normal)
        setBtn.titleLabel?.font = UIFont(name: "Montserrat", size: 20)
        setBtn.backgroundColor = .menuBtns
        setBtn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        setBtn.widthAnchor.constraint(equalToConstant: 334).isActive = true
        setBtn.layer.cornerRadius = 23

        return setBtn
    }()

    lazy var topPlayersButton: UIButton = {
        let topBtn = UIButton(type: .system)
        topBtn.setTitle("Топ Игроков", for: .normal)
        topBtn.setTitleColor(.black, for: .normal)
        topBtn.titleLabel?.font = UIFont(name: "Montserrat", size: 20)
        topBtn.backgroundColor = .menuBtns
        topBtn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        topBtn.widthAnchor.constraint(equalToConstant: 334).isActive = true
        topBtn.layer.cornerRadius = 23

        return topBtn
    }()

    lazy var statisticButton: UIButton = {
        let statBtn = UIButton(type: .system)
        statBtn.setTitle("Моя Статистика", for: .normal)
        statBtn.setTitleColor(.black, for: .normal)
        statBtn.titleLabel?.font = UIFont(name: "Montserrat", size: 20)
        statBtn.backgroundColor = .menuBtns
        statBtn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        statBtn.widthAnchor.constraint(equalToConstant: 334).isActive = true
        statBtn.layer.cornerRadius = 23

        return statBtn
    }()

    lazy var exitButton: UIButton = {
        let exitBtn = UIButton(type: .system)
        exitBtn.setTitle("Выйти", for: .normal)
        exitBtn.setTitleColor(.white, for: .normal)
        exitBtn.titleLabel?.font = UIFont(name: "Montserrat", size: 20)
        exitBtn.backgroundColor = .exitBtnC
        exitBtn.heightAnchor.constraint(equalToConstant: 63).isActive = true
        exitBtn.widthAnchor.constraint(equalToConstant: 334).isActive = true
        exitBtn.layer.cornerRadius = 23

        return exitBtn
    }()


    init() {
        super.init(frame: .zero)
        backgroundColor = .bgCol
        setViews()
        setConstraints()
    }

    //MARK: дизайн view
    func setViews() { }

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
        vStack.addArrangedSubview(topPlayersButton)
        vStack.addArrangedSubview(statisticButton)
        vStack.addArrangedSubview(exitButton)
        vStack.setCustomSpacing(79, after: statisticButton)


        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            logoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 9),
            logoView.widthAnchor.constraint(equalToConstant: 195),
            logoView.heightAnchor.constraint(equalToConstant: 195)
        ])

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 56),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 34),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -34),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }

}

#Preview {
    MenuView()
}
