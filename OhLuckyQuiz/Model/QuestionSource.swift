//
//  QuestionSource.swift
//  OhLuckyQuiz
//

import Foundation

/// Откуда берутся вопросы. Игрок не выбирает: русских вопросов сервер не отдаёт.
enum QuestionSource {

    case online
    case offline

    static var current: QuestionSource {
        guard AppLanguage.current != .ru else { return .offline}
        return AppSettings.playOfflineEnabled ? .offline : .online
    }

    var title: String {
        switch self {
        case .online: return localized("Online")
        case .offline: return localized("Offline")
        }
    }

    /// Хвост бейджа: одно слово «Онлайн» игроку ничего не объясняет.
    var badgeDetail: String {
        switch self {
        case .online: return localized("fresh questions")
        case .offline: return localized("330 questions")
        }
    }

    var explanation: String {
        switch self {
        case .online: return localized("Fresh questions from the server, so every game is new. Needs the internet, and questions come in English only.")
        case .offline: return localized("330 questions are already in the app. They work without a connection, but start repeating over time.")
        }
    }

    var iconName: String {
        switch self {
        case .online: return "cloud"
        case .offline: return "books.vertical"
        }
    }
}
