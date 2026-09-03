//
//  QuestionNetworkService.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

protocol QuestionNetworkServiceType {
    func fetchBatch(category: QuizCategory, difficulty: Difficulty) async throws -> [MultipleQuestion]
}

private struct RemoteConfig: Decodable {
    let apiBaseURL: String
}

class QuestionNetworkService: QuestionNetworkServiceType {
    /// Меняя apiBaseURL в этом файле, можно переключить источник вопросов без релиза приложения.
    private let configURL = URL(string: "https://loag00233.github.io/ohluckyquiz-legal/config.json")!
    private var cachedBaseURL: String?
    private let client = APIClient()

    private func resolveBaseURL() async throws -> String {
        if let cachedBaseURL { return cachedBaseURL }
        let config: RemoteConfig = try await client.request(url: configURL)
        cachedBaseURL = config.apiBaseURL
        return config.apiBaseURL
    }

    private func buildURL(baseURL: String,
                          amount: Int = 5,
                          category: QuizCategory,
                          difficulty: Difficulty
    ) throws -> URL {
        var components = URLComponents(string: "\(baseURL)")
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "amount", value: amount.description),
            URLQueryItem(name: "category", value: category.rawValue.description),
            URLQueryItem(name: "difficulty", value: difficulty.rawValue),
            URLQueryItem(name: "type", value: "multiple"),
            URLQueryItem(name: "encode", value: "url3986")

        ]
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }

    func fetchBatch(category: QuizCategory, difficulty: Difficulty) async throws -> [MultipleQuestion] {
        let baseURL = try await resolveBaseURL()
        let url = try buildURL(baseURL: baseURL, category: category, difficulty: difficulty)
        let response: NetworkModel = try await client.request(url: url)
        try response.validate()

        let questionsArray: [MultipleQuestion] = response.responseResult
        guard !questionsArray.isEmpty else { throw APIError.noResults }

        return questionsArray
    }
}

