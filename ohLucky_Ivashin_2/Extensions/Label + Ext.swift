//
//  Label + Ext.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 31.10.2025.
//

import UIKit

extension UILabel {
    convenience init(text: String,
                     isBold: Bool = false,
                     isLarge: Bool = false,
                     alignement: NSTextAlignment = .center
                     ) {
        self.init()
        self.text = text
        self.textAlignment = alignement
        
        let fontSize: CGFloat = isLarge ? 20 : 16
        let fontBold = isBold ? "Montserrat-Bold" : "Montserrat-Regular"
        self.font = UIFont(name: fontBold, size: fontSize)
    }
    
    func boldDecoration() {
        self.textAlignment = .center
        self.textColor = UIColor(named: "bankColor")
        self.font = UIFont(name: "Montserrat-Bold", size: 16)
    }
    
    func regularDecoration() {
        self.textAlignment = .center
        self.textColor = UIColor(named: "bankColor")
        self.font = UIFont(name: "Montserrat-Regular", size: 16)
    }
}
