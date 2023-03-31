//
//  ItemsResponse.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

struct ItemsResponse<T: Decodable>: Decodable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case items = "Items"
    }
    
    
    // MARK: - Properties
    
    let items: [T]
}
