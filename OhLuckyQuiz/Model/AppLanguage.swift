//
//  AppLanguage.swift
//  OhLuckyQuiz
//

import Foundation

extension Notification.Name {
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
}

/// Язык приложения. По умолчанию берётся из системы, дальше его можно сменить в настройках.
enum AppLanguage: String, CaseIterable {

    case en
    case ru

    private static let storageKey = "appLanguage"

    private(set) static var current: AppLanguage = {
        guard let saved = UserDefaults.standard.string(forKey: storageKey),
              let language = AppLanguage(rawValue: saved) else {
            return systemDefault
        }
        return language
    }()

    static var systemDefault: AppLanguage {
        let code = Locale.preferredLanguages.first ?? "en"
        return code.hasPrefix("ru") ? .ru : .en
    }

    static func select(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)

        guard language != current else { return }

        current = language
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }

    var displayName: String {
        switch self {
        case .en: return "English"
        case .ru: return "Русский"
        }
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}

func localized(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: AppLanguage.current.bundle)
}
