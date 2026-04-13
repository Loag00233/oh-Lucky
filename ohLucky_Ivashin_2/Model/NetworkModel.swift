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
}
