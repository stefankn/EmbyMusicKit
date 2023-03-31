//
//  Collection.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

struct Collection: Decodable {

    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type = "CollectionType"
    }
    
    
    
    // MARK: - Properties
    
    let id: String
    let type: CollectionType
}
