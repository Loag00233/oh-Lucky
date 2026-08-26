//
//  Label + Ext.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 31.10.2025.
//

import UIKit

extension UILabel {
    convenience init(text: String,
                     isBold: Bool = false,
                     isLarge: Bool = false,
                     alignment: NSTextAlignment = .center
                     ) {
        self.init()
        self.text = text
        self.textAlignment = alignment
        
        let fontSize: CGFloat = isLarge ? 20 : 16
        let fontBold = isBold ? "Montserrat-Bold" : "Montserrat-Regular"
        self.font = UIFont(name: fontBold, size: fontSize)
    }
    
    func boldBankCardDecoration() {
        self.textAlignment = .center
        self.textColor = UIColor(named: "bankColor")
        self.font = UIFont(name: "Montserrat-Bold", size: 16)
    }
    
    func regularBankCardDecoration() {
        self.textAlignment = .center
        self.textColor = UIColor(named: "bankColor")
        self.font = UIFont(name: "Montserrat-Regular", size: 16)
    }
    
    func regularAnswersDecoration() {
        self.textAlignment = .center
        self.textColor = UIColor(named: "answersColor")
        self.font = UIFont(name: "Montserrat-Regular", size: 16)
    }
}
