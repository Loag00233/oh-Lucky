//
//  UiColor.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivashin Ivan on 24.10.2025.
//
import UIKit

extension UIColor {

    static func makeGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(named: "GradientStart")!.cgColor,
            UIColor(named: "GradientEnd")!.cgColor
        ]

        //направление градиента
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        return gradientLayer
    }

}
