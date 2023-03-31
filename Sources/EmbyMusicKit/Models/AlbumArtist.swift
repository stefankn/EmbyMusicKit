//
//  AlbumArtist.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

extension Album {
    public struct Artist: Codable {
        
        // MARK: - Types
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case name = "Name"
        }
        
        
        
        // MARK: - Properties
        
        public let id: String
        public let name: String
    }
}
