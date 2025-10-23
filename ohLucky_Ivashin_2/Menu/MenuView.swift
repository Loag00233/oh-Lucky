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
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .white
        return lbl
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
        logoView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            logoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            logoView.widthAnchor.constraint(equalToConstant: 195),
            logoView.heightAnchor.constraint(equalToConstant: 195)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Blah Blah")
    }

}

#Preview {
    MenuView()
}
