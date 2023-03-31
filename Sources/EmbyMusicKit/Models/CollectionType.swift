//
//  CollectionType.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

extension Collection {
    enum CollectionType: String, Decodable {
        case music
        case other
        
        
        
        // MARK: - Construction
        
        init(from decoder: Decoder) throws {
            self = try CollectionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .other
        }
    }
}
