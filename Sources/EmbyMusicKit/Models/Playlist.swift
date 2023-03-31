//
//  Playlist.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 11/02/2023.
//

import Foundation

public struct Playlist: Codable, Identifiable, Hashable {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageTags = "ImageTags"
    }
    
    enum ImageTagsCodingKeys: String, CodingKey {
        case primary = "Primary"
    }
    
    
    
    // MARK: - Properties
    
    public let id: String
    public let name: String
    public let imageTag: String?
    
    
    
    // MARK: - Construction
    
    public init(id: String, name: String, imageTag: String? = nil) {
        self.id = id
        self.name = name
        self.imageTag = imageTag
    }
    
    
    // MARK: Decodable Construction
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let imageTagsContainer = try container.nestedContainer(keyedBy: ImageTagsCodingKeys.self, forKey: .imageTags)
        
        imageTag = try imageTagsContainer.decodeIfPresent(String.self, forKey: .primary)
    }
    
    
    
    // MARK: - Functions
    
    // MARK: Encodable Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        var imageTagsContainer = container.nestedContainer(keyedBy: ImageTagsCodingKeys.self, forKey: .imageTags)
        try imageTagsContainer.encode(imageTag, forKey: .primary)
    }
}
