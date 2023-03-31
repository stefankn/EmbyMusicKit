//
//  Artist.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 03/02/2023.
//

import Foundation

public struct Artist: Decodable, Identifiable, Equatable, Hashable {

    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case overview = "Overview"
        case imageTags = "ImageTags"
        case backdropImageTags = "BackdropImageTags"
        case externalURLs = "ExternalUrls"
        case genres = "Genres"
    }
    
    enum ImageTagsCodingKeys: String, CodingKey {
        case primary = "Primary"
        case logo = "Logo"
    }
    
    
    
    // MARK: - Properties
    
    public let id: String
    public let name: String
    public let overview: String?
    public let imageTag: String?
    public let logoTag: String?
    public let backdropImageTags: [String]
    public let externalURLs: [ExternalURL]
    public let genres: [String]?
    
    public var backdropImageTag: String? {
        backdropImageTags.first
    }
    
    
    
    // MARK: - Construction
    
    public init(id: String, name: String, overview: String? = nil, imageTag: String? = nil, logoTag: String? = nil, backdropImageTags: [String] = [], externalURLs: [ExternalURL] = [], genres: [String]? = nil) {
        self.id = id
        self.name = name
        self.overview = overview
        self.imageTag = imageTag
        self.logoTag = logoTag
        self.backdropImageTags = backdropImageTags
        self.externalURLs = externalURLs
        self.genres = genres
    }
    
    
    // MARK: Decodable Construction
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        backdropImageTags = try container.decode([String].self, forKey: .backdropImageTags)
        externalURLs = try container.decodeIfPresent([ExternalURL].self, forKey: .externalURLs) ?? []
        genres = try container.decodeIfPresent([String].self, forKey: .genres)
        
        let imageTagsContainer = try container.nestedContainer(keyedBy: ImageTagsCodingKeys.self, forKey: .imageTags)
        imageTag = try imageTagsContainer.decodeIfPresent(String.self, forKey: .primary)
        logoTag = try imageTagsContainer.decodeIfPresent(String.self, forKey: .logo)
    }
    
    
    
    // MARK: - Functions
    
    // MARK: Equatable Functions
    
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.id == rhs.id
    }
    
    
    // MARK: Hashable Functions
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
