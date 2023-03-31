//
//  Album.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation

public struct Album: Codable, Identifiable, Hashable, CustomStringConvertible {
    
    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case artists = "ArtistItems"
        case albumArtist = "AlbumArtist"
        case albumArtists = "AlbumArtists"
        case imageTags = "ImageTags"
        case parentBackdropImageTags = "ParentBackdropImageTags"
    }
    
    enum ImageTagCodingKeys: String, CodingKey {
        case primary = "Primary"
    }
    
    
    
    // MARK: - Properties
    
    public let id: String
    public let name: String
    public let artists: [Artist]
    public let albumArtist: String
    public let albumArtists: [Artist]
    public let imageTag: String?
    public let backdropImageTag: String?
    
    public var artistsDescription: String {
        artists.map{ $0.name }.joined(separator: ", ")
    }
    
    
    // MARK: CustomStringConvertible Properties
    
    public var description: String {
        "\(albumArtist) - \(name)"
    }
    
    
    // MARK: - Construction
    
    public init(id: String, name: String, albumArtist: String, artists: [Artist] = [], albumArtists: [Artist] = [], imageTag: String? = nil, backdropImageTag: String? = nil) {
        self.id = id
        self.name = name
        self.albumArtist = albumArtist
        self.artists = artists
        self.albumArtists = albumArtists
        self.imageTag = imageTag
        self.backdropImageTag = backdropImageTag
    }
    
    
    // MARK: Decodable Construction
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        albumArtist = try container.decode(String.self, forKey: .albumArtist)
        artists = try container.decode([Artist].self, forKey: .artists)
        albumArtists = try container.decode([Artist].self, forKey: .albumArtists)
        backdropImageTag = try container.decodeIfPresent([String].self, forKey: .parentBackdropImageTags)?.first
        
        let imageTagsContainer = try container.nestedContainer(keyedBy: ImageTagCodingKeys.self, forKey: .imageTags)
        imageTag = try imageTagsContainer.decodeIfPresent(String.self, forKey: .primary)
    }
    
    
    // MARK: - Functions
    
    // MARK: Encodable Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(albumArtist, forKey: .albumArtist)
        try container.encode(artists, forKey: .artists)
        try container.encode(albumArtists, forKey: .albumArtists)
        
        var imageTagsContainer = container.nestedContainer(keyedBy: ImageTagCodingKeys.self, forKey: .imageTags)
        try imageTagsContainer.encode(imageTag, forKey: .primary)
    }
    
    
    // MARK: Equatable Functions
    
    public static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
    
    
    // MARK: Hashable Functions
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
