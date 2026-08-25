//
//  AppLanguage.swift
//  ohLucky_Ivashin_2
//

import Foundation

extension Notification.Name {
    /// Экраны, живые в момент переключения, обновляют по нему свои подписи
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
        // пишем всегда: выбор того же языка, что показан сейчас, тоже выбор,
        // иначе смена языка телефона позже перебьёт его
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)

        guard language != current else { return }

        current = language
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }

    /// Название языка пишется на нём самом и не переводится
    var displayName: String {
        switch self {
        case .en: return "English"
        case .ru: return "Русский"
        }
    }

    /// Бандл с переводами именно этого языка.
    ///
    /// Откат на Bundle.main здесь опасен: main подбирает локализацию по языку системы,
    /// и на русском телефоне английский текст молча превратится в русский. Поэтому
    /// в каталоге для английского заведены явные записи — только ради того, чтобы
    /// сборка положила в бандл en.lproj. Если он пропадёт, переключение языка сломается.
    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}

/// Замена String(localized:) — берёт перевод из языка приложения, а не системы.
/// Эту обёртку Xcode не распознаёт и новые строки в каталог сам не добавляет:
/// заводя вызов, добавьте ключ в Localizable.xcstrings руками.
func localized(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: AppLanguage.current.bundle)
}
