//
//  String + Ext.swift
//  ohLucky_Ivashin_2
//

import Foundation

extension Int {

    private static let scoreFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal // группировка разрядов без десятичных знаков
        f.groupingSeparator = "\u{00A0}" // неразрывный пробел, не зависит от локали устройства
        f.groupingSize = 3
        f.maximumFractionDigits = 0
        return f
    }()

    var formattedScore: String {
        Self.scoreFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
