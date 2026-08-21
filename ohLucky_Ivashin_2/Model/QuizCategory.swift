//
//  QuizCategory.swift
//  ohLucky_Ivashin_2
//

import Foundation

enum QuizCategory: Int, CaseIterable {
    case generalKnowledge = 9
    case film = 11
    case music = 12
    case television = 14
    case videoGames = 15
    case scienceNature = 17
    case computers = 18
    case sports = 21
    case geography = 22
    case history = 23
    case animals = 27

    var displayName: String {
        switch self {
        case .generalKnowledge: return String(localized: "General Knowledge")
        case .film: return String(localized: "Film")
        case .music: return String(localized: "Music")
        case .television: return String(localized: "Television")
        case .videoGames: return String(localized: "Video Games")
        case .scienceNature: return String(localized: "Science & Nature")
        case .computers: return String(localized: "Computers")
        case .sports: return String(localized: "Sports")
        case .geography: return String(localized: "Geography")
        case .history: return String(localized: "History")
        case .animals: return String(localized: "Animals")
        }
    }
}
