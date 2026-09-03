//
//  UiColor.swift
//  OhLuckyQuiz
//
//  Created by Ivashin Ivan on 24.10.2025.
//
import UIKit

extension UIColor {

    static func makeGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.gradientStart.cgColor,
            UIColor.gradientEnd.cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        return gradientLayer
    }

}

final class GradientView: UIView {
    private let gradient = UIColor.makeGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradient, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
    }
}
