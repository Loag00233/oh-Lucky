//
//  QuestionNetworkService.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

protocol QuestionNetworkServiceType {
    func fetchQuestions(isMultiple: Bool) async throws -> [MultipleQuestion]
}

class QuestionNetworkService: QuestionNetworkServiceType {
    private let baseURL = "https://opentdb.com/api.php"
    private let client = APIClient()
    
    private func buildURL(amount: Int = 5, category: Int = 9, difficulty: Difficulty, isMultiple: Bool) throws -> URL {
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
    
    func fetchQuestions(isMultiple: Bool) async throws -> [MultipleQuestion] {
                
        let easyURL = try buildURL(difficulty: .easy, isMultiple: isMultiple)
        let easyResponse: NetworkModel = try await client.request(url: easyURL)
        
        let mediumURL = try buildURL(difficulty: .medium, isMultiple: isMultiple)
        let mediumResponse: NetworkModel = try await client.request(url: mediumURL)
        
        let hardURL = try buildURL(difficulty: .hard, isMultiple: isMultiple)
        let hardResponse: NetworkModel = try await client.request(url: hardURL)
        
        let questionsArray: [MultipleQuestion] = easyResponse.responseResult + mediumResponse.responseResult + hardResponse.responseResult
        
        return questionsArray
        
    }
}


