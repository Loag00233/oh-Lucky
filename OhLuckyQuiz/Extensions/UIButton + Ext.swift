//
//  UIButton + Ext.swift
//  OhLuckyQuiz
//

import UIKit

extension UIButton {

    /// Малая кнопка «Назад» в углу экрана.
    static func backPill(identifier: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(localized("Back"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .montserrat(16, bold: true)
        btn.backgroundColor = .exitBtnC
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btn.layer.cornerRadius = Radius.pill(32)
        btn.accessibilityIdentifier = identifier
        return btn
    }

    /// Крупная кнопка действия во всю ширину колонки.
    static func action(title: String,
                       titleColor: UIColor,
                       background: UIColor? = nil,
                       isBold: Bool = true,
                       width: CGFloat? = nil,
                       identifier: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.styleAsAction(title: title, titleColor: titleColor, background: background,
                          isBold: isBold, width: width, identifier: identifier)
        return btn
    }

    /// Та же форма для подкласса с собственной отрисовкой — GradientButton в меню.
    func styleAsAction(title: String,
                       titleColor: UIColor,
                       background: UIColor? = nil,
                       isBold: Bool = true,
                       width: CGFloat? = nil,
                       identifier: String) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = .montserrat(20, bold: isBold)
        backgroundColor = background
        heightAnchor.constraint(equalToConstant: 63).isActive = true
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        layer.cornerRadius = Radius.card
        accessibilityIdentifier = identifier
    }
}
