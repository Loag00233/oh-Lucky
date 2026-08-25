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
        case .generalKnowledge: return localized("General Knowledge")
        case .film: return localized("Film")
        case .music: return localized("Music")
        case .television: return localized("Television")
        case .videoGames: return localized("Video Games")
        case .scienceNature: return localized("Science & Nature")
        case .computers: return localized("Computers")
        case .sports: return localized("Sports")
        case .geography: return localized("Geography")
        case .history: return localized("History")
        case .animals: return localized("Animals")
        }
    }
}
