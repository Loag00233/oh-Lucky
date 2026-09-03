//
//  Label + Ext.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 31.10.2025.
//

import UIKit

extension UIFont {

    static func montserrat(_ size: CGFloat, bold: Bool = false) -> UIFont? {
        UIFont(name: bold ? "Montserrat-Bold" : "Montserrat-Regular", size: size)
    }
}

/// Скругления в двух стилях: крупные поверхности — общий фиксированный радиус,
/// мелкие управляющие элементы — скругление во всю высоту. Разнобой в числах
/// читался как элементы из разных наборов: «Выйти» и «50:50» стояли рядом с 0,375 и 0,5.
enum Radius {

    /// Карточки, плитки и кнопки во всю ширину колонки.
    static let card: CGFloat = 20

    /// Пилюля: скругление на половину высоты. Передавай то же число, что стоит
    /// в heightAnchor.constraint(equalToConstant:) этого элемента
    static func pill(_ height: CGFloat) -> CGFloat { height / 2 }
}

extension UILabel {
    convenience init(text: String,
                     isBold: Bool = false,
                     isLarge: Bool = false,
                     alignment: NSTextAlignment = .center
                     ) {
        self.init()
        self.text = text
        self.textAlignment = alignment
        self.font = .montserrat(isLarge ? 20 : 16, bold: isBold)
    }

    func decorate(color: UIColor, bold: Bool = false) {
        self.textAlignment = .center
        self.textColor = color
        self.font = .montserrat(16, bold: bold)
    }
}
