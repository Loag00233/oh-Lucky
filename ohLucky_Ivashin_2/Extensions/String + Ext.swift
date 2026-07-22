//
//  String + Ext.swift
//  ohLucky_Ivashin_2
//

import Foundation

extension String {
    /// Декодирует HTML-сущности, которые OpenTDB подставляет в текст (&quot;, &#039;, &amp; и т.д.)
    func htmlEntityDecoded() -> String {
        let entities: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&rsquo;": "\u{2019}",
            "&lsquo;": "\u{2018}",
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}",
            "&hellip;": "\u{2026}",
            "&ndash;": "\u{2013}",
            "&mdash;": "\u{2014}",
        ]

        var result = self
        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        return result
    }
}
