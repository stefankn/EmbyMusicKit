//
//  EmbyService.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation
import SwiftCore
import AVFoundation

public final class EmbyService: Service {
    
    // MARK: - Types
    
    enum APIError: Error {
        case authenticationRequired
    }
    
    enum ItemType: String {
        case musicAlbum = "MusicAlbum"
        case audio = "Audio"
        case playlist = "Playlist"
    }
    
    public enum ArtistType: String {
        case artist = "Artist"
        case albumArtist = "AlbumArtist"
    }
    
    
    // MARK: - Private Properties
    
    private let config: ConfigService
    
    
    
    // MARK: - Properties
    
    // MARK: Service Properties
    
    public override var baseURL: URL? {
        if let host = config.host {
            return URL("http://\(host)")
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Construction
    
    public init(config: ConfigService = ConfigService(keychain: Keychain())) {
        self.config = config
    }
    
    
    
    // MARK: - Functions
    
    public func getMusicAlbums(from artist: Artist? = nil, sorting: ItemSorting = .name(.ascending)) async throws -> [Album] {
        let user = try assertAuthenticated()
        
        var parameters: Parameters = [
            ("Recursive", true),
            ("IncludeItemTypes", ItemType.musicAlbum.rawValue),
            ("Fields", "BasicSyncInfo,PrimaryImageAspectRatio,Prefix"),
            ("EnableImageTypes", "Primary,Backdrop,Thumb"),
            ("ImageTypeLimit", 1)
        ]
        parameters.append(contentsOf: sorting.parameters)
        
        if let artist = artist {
            parameters += [
                ("AlbumArtistIds", artist.id)
            ]
        } else if let collectionId = try await getCollections().first(where: { $0.type == .music })?.id {
            parameters += [
                ("ParentId", collectionId)
            ]
        }
        
        let response: ItemsResponse<Album> = try await get("/emby/Users/\(user.id)/Items", parameters: parameters)
        
        return response.items
    }
    
    public func getPlaylists() async throws -> [Playlist] {
        if let collectionId = try await getCollections().first(where: { $0.type == .music })?.id {
            let user = try assertAuthenticated()
            
            let parameters: Parameters = [
                ("ParentId", collectionId),
                ("Recursive", true),
                ("IncludeItemTypes", ItemType.playlist.rawValue),
                ("Fields", "BasicSyncInfo,PrimaryImageAspectRatio,Prefix"),
                ("EnableImageTypes", "Primary,Backdrop,Thumb"),
                ("ImageTypeLimit", 1),
                ("SortBy", "SortName"),
                ("SortOrder", "Ascending")
            ]
            
            let response: ItemsResponse<Playlist> = try await get("/emby/Users/\(user.id)/Items", parameters: parameters)
            
            return response.items
        } else {
            return []
        }
    }
    
    public func createPlaylist(name: String, tracks: [Track]) async throws {
        try assertAuthenticated()
        
        let parameters: Parameters = [
            ("Name", name),
            ("Ids", tracks.map{ $0.id }.joined(separator: ","))
        ]
        
        try await post("/emby/Playlists", parameters: parameters)
    }
    
    public func add(_ tracks: [Track], to playlist: Playlist) async throws {
        try assertAuthenticated()
        
        let parameters: Parameters = [
            ("Ids", tracks.map{ $0.id }.joined(separator: ","))
        ]
        
        try await post("/emby/Playlists/\(playlist.id)/Items", parameters: parameters)
    }
    
    public func remove(_ tracks: [Track], from playlist: Playlist) async throws {
        try assertAuthenticated()
        
        let parameters: Parameters = [
            ("EntryIds", tracks.compactMap{ $0.playlistItemId }.joined(separator: ","))
        ]
        
        try await post("/emby/Playlists/\(playlist.id)/Items/Delete", parameters: parameters)
    }
    
    public func remove(_ playlist: Playlist) async throws {
        try assertAuthenticated()
        
        try await post("/emby/Items/\(playlist.id)/Delete")
    }
    
    public func getTracks(from artist: Artist, sorting: ItemSorting = .playCount(.descending)) async throws -> [Track] {
        let user = try assertAuthenticated()
        
        var parameters: Parameters = [
            ("ArtistIds", artist.id),
            ("Recursive", true),
            ("IncludeItemTypes", ItemType.audio.rawValue),
            ("Fields", "PrimaryImageAspectRatio"),
            ("ImageTypeLimit", 1)
        ]
        parameters.append(contentsOf: sorting.parameters)
        
        let response: ItemsResponse<Track> = try await get("/emby/Users/\(user.id)/Items", parameters: parameters)
        return response.items
    }
    
    public func getTracks(for album: Album, sorting: ItemSorting = .index(.ascending)) async throws -> [Track] {
        try await getTracks(itemId: album.id, sorting: sorting)
    }
    
    public func getTracks(for playlist: Playlist, sorting: ItemSorting = .listItem(.ascending)) async throws -> [Track] {
        try await getTracks(itemId: playlist.id, sorting: sorting)
    }
    
    public func getTracks(itemId: String, sorting: ItemSorting) async throws -> [Track] {
        let user = try assertAuthenticated()
        
        var parameters: Parameters = [
            ("ParentId", itemId),
            ("Recursive", true),
            ("IncludeItemTypes", ItemType.audio.rawValue),
            ("Fields", "PrimaryImageAspectRatio"),
            ("EnableImageTypes", "Primary,Backdrop,Thumb"),
            ("ImageTypeLimit", 1)
        ]
        parameters.append(contentsOf: sorting.parameters)
        
        let response: ItemsResponse<Track> = try await get("/emby/Users/\(user.id)/Items", parameters: parameters)
        
        return response.items
    }
    
    func getCollections() async throws -> [Collection] {
        let user = try assertAuthenticated()
        
        let response: ItemsResponse<Collection> = try await get("/emby/Users/\(user.id)/Views")
        return response.items
    }
    
    public func getArtists(type: ArtistType = .artist, sorting: ItemSorting = .name(.ascending)) async throws -> [Artist] {
        try assertAuthenticated()
        var parameters: Parameters = [
            ("ArtistType", type.rawValue)
        ]
        parameters.append(contentsOf: sorting.parameters)

        let response: ItemsResponse<Artist> = try await get("/emby/Artists", parameters: parameters)
        
        return response.items
    }
    
    public func getArtist(with id: String) async throws -> Artist {
        let user = try assertAuthenticated()
        
        return try await get("/emby/Users/\(user.id)/Items/\(id)")
    }
    
    public func systemInfo() async throws -> SystemInfo {
        try await get("/emby/System/Info")
    }
    
    public func endpoint() async throws -> Endpoint {
        try assertAuthenticated()
        
        return try await get("/emby/System/Endpoint")
    }
    
    public func imageURL(for album: Album) -> URL? {
        if let imageTag = album.imageTag {
            return URL(string: "/emby/Items/\(album.id)/Images/Primary?maxHeight=400&maxWidth=400&tag=\(imageTag)&quality=90", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    public func imageURL(for artist: Artist) -> URL? {
        if let imageTag = artist.imageTag {
            return URL(string: "/emby/Items/\(artist.id)/Images/Primary?maxHeight=400&maxWidth=400&tag=\(imageTag)&quality=90", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    public func backdropImageURL(for artist: Artist) -> URL? {
        if let imageTag = artist.backdropImageTag {
            return URL(string: "/emby/Items/\(artist.id)/Images/Backdrop?tag=\(imageTag)&maxWidth=3840&quality=70", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    public func imageURL(for track: Track) -> URL? {
        if let imageTag = track.albumImageTag {
            return URL(string: "/emby/Items/\(track.albumId)/Images/Primary?maxHeight=400&maxWidth=400&tag=\(imageTag)&quality=90", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    public func imageURL(for playlist: Playlist) -> URL? {
        if let imageTag = playlist.imageTag {
            return URL(string: "/emby/Items/\(playlist.id)/Images/Primary?maxHeight=400&maxWidth=400&tag=\(imageTag)&quality=90", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    public func imageURL(for user: AuthenticatedUser) -> URL? {
        if let imageTag = user.imageTag {
            return URL(string: "/emby/Users/\(user.id)/images/Primary?maxHeight=400&maxWidth=400&tag=\(imageTag)", relativeTo: baseURL)
        } else {
            return nil
        }
    }
    
    public func asset(for track: Track, network: PlayerService.Network) throws -> AVURLAsset? {
        guard
            let host = config.host,
            let url = URL(string: "http://\(host)/emby/Audio/\(track.id)/universal") else { return nil }
        
        let accessToken = try assertAuthenticated().accessToken
        
        let headers: [String: String] = [
            "X-Emby-Token": accessToken
        ]
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "MaxStreamingBitrate", value: "\(network.maxStreamingBitrate)"),
            URLQueryItem(name: "Container", value: "mp3|mp3,mp2,mp3|mp2,aac|aac,m4a|aac,flac,webma,webm,wav|PCM_S16LE,wav|PCM_S24LE"),
            URLQueryItem(name: "TranscodingContainer", value: "aac"),
            URLQueryItem(name: "TranscodingProtocol", value: "hls"),
            URLQueryItem(name: "AudioCodec", value: "aac"),
            URLQueryItem(name: "PlaySessionId", value: "\(track.id)")
        ]
        
        if let url = components?.url {
            return AVURLAsset(
                url: url,
                options: [
                    "AVURLAssetHTTPHeaderFieldsKey": headers,
                    //AVURLAssetAllowsCellularAccessKey: false
                ]
            )
        } else {
            return nil
        }
    }
    
    
    // MARK: Service Functions
    
    public override func prepare(_ request: URLRequest) async throws -> URLRequest {
        var request = try await super.prepare(request)
        
        if let accessToken = config.user?.accessToken {
            request.setValue(accessToken, forHTTPHeaderField: "X-Emby-Token")
        }
        
        return request
    }
    
    
    
    // MARK: - Private Functions
    
    @discardableResult func assertAuthenticated() throws -> AuthenticatedUser {
        if let user = config.user {
            return user
        } else {
            throw APIError.authenticationRequired
        }
    }
}
