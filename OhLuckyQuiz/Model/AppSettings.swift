//
//  AppSettings.swift
//  OhLuckyQuiz
//

import Foundation

/// Звук и вибрация — раздельно, не одним тумблером: в беззвучном режиме играют многие,
/// а тактильность при этом любят.
enum AppSettings {

    private static let soundKey = "soundEnabled"
    private static let hapticsKey = "hapticsEnabled"
    private static let onboardingKey = "hasSeenOnboarding"
    private static let playOfflineKey = "playOffline"

    static var soundEnabled: Bool {
        get { isOn(soundKey) }
        set { UserDefaults.standard.set(newValue, forKey: soundKey) }
    }

    static var hapticsEnabled: Bool {
        get { isOn(hapticsKey) }
        set { UserDefaults.standard.set(newValue, forKey: hapticsKey) }
    }

    static var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }
    
    static var playOfflineEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: playOfflineKey) }
        set { UserDefaults.standard.set(newValue, forKey: playOfflineKey) }
    }

    /// `bool(forKey:)` на незаданном ключе отдаёт `false`, а обе настройки по умолчанию включены —
    /// поэтому проверяем именно наличие значения.
    private static func isOn(_ key: String) -> Bool {
        UserDefaults.standard.object(forKey: key) as? Bool ?? true
    }
}
