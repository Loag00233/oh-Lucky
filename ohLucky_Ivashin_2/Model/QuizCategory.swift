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
        case .generalKnowledge: return "General Knowledge"
        case .film: return "Film"
        case .music: return "Music"
        case .television: return "Television"
        case .videoGames: return "Video Games"
        case .scienceNature: return "Science & Nature"
        case .computers: return "Computers"
        case .sports: return "Sports"
        case .geography: return "Geography"
        case .history: return "History"
        case .animals: return "Animals"
        }
    }
}
