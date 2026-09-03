//
//  APIError.swift
//  OhLuckyQuiz
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noResults
    case invalidParameter
    case tokenNotFound
    
}
