//
//  APIError.swift
//  ohLucky_Ivashin_2
//
//  Created by Ivan Ivashin on 10.04.2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noResults
    case invalidParametr
    case tokenNotFound
    case tokenEmpty
    case rateLimit
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: "Could not establish connection to server. Check URL"
        case .noResults: "Could not return results. The API doesn't have enough questions for your query."
        case .invalidParametr: "Contains an invalid parameter. Arguements passed in aren't valid."
        case .tokenNotFound: "Session Token does not exist."
        case .tokenEmpty: "Session Token has returned all possible questions for the specified query. Resetting the Token is necessary."
        case .rateLimit: "Too many requests have occurred. Each IP can only access the API once every 5 seconds."
        }
    }
}
