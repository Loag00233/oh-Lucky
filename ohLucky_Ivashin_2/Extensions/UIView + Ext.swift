//
//  UIView + Ext.swift
//  ohLucky_Ivashin_2
//

import UIKit

extension UIView {

    // Колонка, к которой крепится контент экрана: по центру, с отступами по краям,но не шире maxWidth — иначе на iPad строки растягиваются во всю ширину экрана.
    func makeContentGuide(inset: CGFloat = 34, maxWidth: CGFloat = 700) -> UILayoutGuide {
        let guide = UILayoutGuide()
        addLayoutGuide(guide)

        let insetWidth = guide.widthAnchor.constraint(equalTo: widthAnchor, constant: -inset * 2)
        insetWidth.priority = .defaultHigh // уступает ограничению maxWidth на широких экранах

        NSLayoutConstraint.activate([
            guide.centerXAnchor.constraint(equalTo: centerXAnchor),
            guide.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            insetWidth
        ])

        return guide
    }
}
