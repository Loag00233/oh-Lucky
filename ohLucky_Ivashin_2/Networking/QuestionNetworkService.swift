//
//  QuestionNetworkService.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

//protocol QuestionNetworkServiceType {
//    func fetchQuestions(isMultiple: Bool) async throws -> [MultipleQuestion]
//}

class QuestionNetworkService/*: QuestionNetworkServiceType*/ {
    private let baseURL = "https://opentdb.com/api.php"
    private let client = APIClient()
    
    private func buildURL(amount: Int = 5,
                          category: Int = 9,
                          difficulty: Difficulty,
                          isMultiple: Bool) throws -> URL {
        var components = URLComponents(string: "\(baseURL)")
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "amount", value: amount.description),
            URLQueryItem(name: "category", value: category.description),
            URLQueryItem(name: "difficulty", value: difficulty.rawValue),
            URLQueryItem(name: "type", value: isMultiple ? "multiple" : "boolean")
        ]
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }
    
    func fetchBatch(difficulty: Difficulty, isMultiple: Bool) async throws -> [MultipleQuestion] {
        let easyURL = try buildURL( difficulty: .easy, isMultiple: isMultiple)
        let easyResponse: NetworkModel = try await client.request(url: easyURL)
        
        let questionsArray: [MultipleQuestion] = easyResponse.responseResult
        
        return questionsArray
    }
}

