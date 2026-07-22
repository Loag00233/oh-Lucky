//
//  NetworkModel.swift
//  ohLucky_Ivashin_2
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

    /// Проверяет responseCode из OpenTDB и выбрасывает соответствующую ошибку, если запрос не удался
    func validate() throws {
        switch responseCode {
        case 0: return
        case 1: throw APIError.noResults
        case 2: throw APIError.invalidParametr
        case 3: throw APIError.tokenNotFound
        case 4: throw APIError.tokenEmpty
        case 5: throw APIError.rateLimit
        default: throw APIError.noResults
        }
    }
}
