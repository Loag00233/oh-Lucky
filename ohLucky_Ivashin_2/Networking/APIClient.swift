//
//  APIClient.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init() {
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func request<T:Decodable>(url: URL) async throws -> T {
        let (data, _) = try await session.data(from: url)
        return try decoder.decode(T.self, from: data)
    }
}
