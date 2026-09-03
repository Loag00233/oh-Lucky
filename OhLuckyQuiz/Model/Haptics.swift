//
//  Haptics.swift
//  OhLuckyQuiz
//

import UIKit

/// Общие генераторы с `prepare()`: создавать новый на каждый ответ — значит ловить задержку
/// первого срабатывания. Taptic Engine есть только на iPhone, на iPad вызовы просто ничего
/// не сделают, отдельной ветки для него не нужно.
@MainActor
enum Haptics {

    private static let notification = UINotificationFeedbackGenerator()
    private static let impact = UIImpactFeedbackGenerator(style: .light)

    static func prepare() {
        guard AppSettings.hapticsEnabled else { return }
        notification.prepare()
        impact.prepare()
    }

    /// Выбор варианта ответа.
    static func tap() {
        guard AppSettings.hapticsEnabled else { return }
        impact.impactOccurred()
        impact.prepare()
    }

    static func answer(isCorrect: Bool) {
        guard AppSettings.hapticsEnabled else { return }
        notification.notificationOccurred(isCorrect ? .success : .error)
        notification.prepare()
    }
}
