//
//  Track.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 12/01/2023.
//

import Foundation
import SwiftCore

public struct Track: Codable, Identifiable, Equatable, Comparable, CustomStringConvertible {

    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case albumId = "AlbumId"
        case albumName = "Album"
        case name = "Name"
        case artists = "ArtistItems"
        case index = "IndexNumber"
        case runtimeTicks = "RunTimeTicks"
        case albumImageTag = "AlbumPrimaryImageTag"
        case disc = "ParentIndexNumber"
        case playlistItemId = "PlaylistItemId"
    }
    
    
    
    // MARK: - Private Properties
    
    private let runtimeTicks: Int
    
    
    
    // MARK: - Properties
    
    public let id: String
    public let albumId: String
    public let albumName: String
    public let name: String
    public let artists: [Artist]
    public let albumImageTag: String?
    public let index: Int?
    public let playlistItemId: String?
    
    @DecodableDefault.One
    public var disc: Int
    
    public var sortKey: Int {
        disc * 1000 + (index ?? 0)
    }
    
    public var indexDescription: String {
        if let index = index {
            return "\(index)"
        } else {
            return ""
        }
    }
    
    public var artistsDescription: String {
        artists.map{ $0.name }.joined(separator: ", ")
    }
    
    public var duration: Duration {
        .microTicks(runtimeTicks)
    }
    
    public var durationDescription: String {
        duration.formatted(Duration.TimeFormatStyle(pattern: (duration.seconds / 60) >= 60 ? .hourMinuteSecond : .minuteSecond))
    }
    
    public var contextId: String {
        id + (playlistItemId ?? "")
    }
    
    
    // MARK: CustomStringConvertible Properties
    
    public var description: String {
        "\(disc).\(index ?? 0): \(artistsDescription) - \(name)"
    }
    
    
    
    // MARK: - Construction
    
    public init(id: String, albumId: String, albumName: String, name: String, artists: [Artist] = [], albumImageTag: String? = nil, index: Int? = nil, runtimeTicks: Int = 100_000, disc: Int = 1, playlistItemId: String? = nil) {
        self.id = id
        self.albumId = albumId
        self.albumName = albumName
        self.name = name
        self.artists = artists
        self.albumImageTag = albumImageTag
        self.index = index
        self.runtimeTicks = runtimeTicks
        self.disc = disc
        self.playlistItemId = playlistItemId
    }
    
    
    
    // MARK: - Functions
    
    // MARK: Equatable Functions
    
    public static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id && lhs.playlistItemId == rhs.playlistItemId
    }
    
    
    // MARK: Comparable Functions
    
    public static func < (lhs: Track, rhs: Track) -> Bool {
        lhs.sortKey < rhs.sortKey
    }
}
