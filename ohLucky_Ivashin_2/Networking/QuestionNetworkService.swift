//
//  QuestionNetworkService.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

protocol QuestionNetworkServiceType {
    func fetchMultipleQuestions() -> [MultipleQuestion]
    
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
            URLQueryItem(name: "isMultiple", value: isMultiple.description)
        ]
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }
    
    func fetchMultipleQuestions() -> [MultipleQuestion] {
        //create URL
        // send query
        // get 5 questions
    }
}
