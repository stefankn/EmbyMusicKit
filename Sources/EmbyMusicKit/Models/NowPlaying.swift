//
//  NowPlaying.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 19/01/2023.
//

import Foundation

public struct NowPlaying: Codable {
    
    // MARK: - Properties
    
    public let track: Track
    public let album: Album?
    public let playlist: Playlist?
    public let queue: [Track]
    
    public var history: [Track] {
        if let index = queue.firstIndex(of: track) {
            if index > 0 {
                return Array(queue.prefix(upTo: index))
            }
        }
        
        return []
    }
    
    public var next: [Track] {
        if let index = queue.firstIndex(of: track) {
            if index + 1 < queue.count {
                return Array(queue.suffix(from: index + 1))
            }
        }
        
        return []
    }
    
    
    
    // MARK: - Construction
    
    public init(_ track: Track, album: Album? = nil, playlist: Playlist? = nil, queue: [Track] = []) {
        self.track = track
        self.album = album
        self.playlist = playlist
        self.queue = album != nil ? queue.sorted() : queue // Keep current order for playlists
    }
}
