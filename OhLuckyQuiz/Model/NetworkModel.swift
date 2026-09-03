//
//  NetworkModel.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

struct NetworkModel: Decodable {
    let responseCode: Int
    let responseResult: [MultipleQuestion]

    enum CodingKeys: String, CodingKey {
        case responseResult = "results"
        case responseCode
    }

    /// responseCode от самого OpenTDB
    func validate() throws {
        switch responseCode {
        case 0: return
        case 1: throw APIError.noResults
        case 2: throw APIError.invalidParameter
        case 3: throw APIError.tokenNotFound
        default: throw APIError.noResults
        }
    }
}
