//
//  PlayerService.swift
//  Linnet
//
//  Created by Stefan Klein Nulent on 07/01/2023.
//

import Foundation
import Combine
import MediaPlayer

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class PlayerService {
    
    // MARK: Types
    
    public enum Network {
        case local
        case remote
        
        var maxStreamingBitrate: Int {
            switch self {
            case .local:
                return 140_000_000
            case .remote:
                return 1_500_000
            }
        }
    }
    
    
    
    // MARK: - Private Properties
    
    private let player = AVQueuePlayer()
    private var assetMapping: [AVAsset: Track] = [:]
    private let emby: EmbyService
    private var subscriptions: Set<AnyCancellable> = []
    private var token: Any?
    private var isInitialLoad = true
    private var network: Network = .remote
    
    
    
    // MARK: - Properties
    
    @Published public var status: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
    @Published public var current: NowPlaying? {
        didSet { UserDefaults.standard.set(try? JSONEncoder().encode(current), for: .nowPlaying) }
    }
    @Published public var currentPlaybackPosition: Duration?
    
    
    
    // MARK: - Construction
    
    public init(emby: EmbyService) {
        self.emby = emby
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
        } catch {
            assertionFailure("Failed to configure `AVAAudioSession`: \(error.localizedDescription)")
        }
        
        setupRemoteControl()
        
        player
            .publisher(for: \.timeControlStatus)
            .assign(to: \.status, on: self)
            .store(in: &subscriptions)
        
        player.publisher(for: \.currentItem)
            .sink { self.playerItemUpdate($0) }
            .store(in: &subscriptions)
        
        token = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 10),
            queue: .main
        ) { [weak self] time in
            self?.currentPlaybackPosition = Duration.seconds(time.seconds)
        }
        
        restoreSession()
    }
    
    
    
    // MARK: - Functions
    
    public func load(_ track: Track, album: Album? = nil, playlist: Playlist? = nil, queuing queue: [Track] = [], play: Bool = true) {
        guard !isPlaying(track) else { return }
        
        let current = NowPlaying(track, album: album, queue: queue)
        self.current = current
        
        isInitialLoad = true
        load([track] + current.next, play: play)
    }
    
    public func playFromQueue(_ track: Track) {
        guard let current = current, current.queue.contains(track) else { return }
        
        load(track, album: current.album, playlist: current.playlist, queuing: current.queue)
    }
    
    public func isPlaying(_ track: Track) -> Bool {
        current?.track == track
    }
    
    public func play() {
        player.play()
        updateInfoCenter()
    }
    
    public func pause() {
        player.pause()
        updateInfoCenter()
    }
    
    public func next() {
        player.advanceToNextItem()
    }
    
    public func reset() {
        player.pause()
        player.removeAllItems()
        
        current = nil
    }
    
    public func previous() {
        if let current = current {
            if let position = currentPlaybackPosition, position > .seconds(10) {
                seek(to: .zero)
            } else if let track = current.history.last {
                load(track, album: current.album, playlist: current.playlist, queuing: current.queue, play: status == .playing)
            }
        }
    }
    
    public func seekBackward() {
        guard status == .playing else { return }

        let newPlaybackPosition = max(Duration.zero, player.currentTimeDuration - .seconds(5))
        player.seek(to: newPlaybackPosition) { _ in
            self.updateInfoCenter()
        }
    }

    public func seekForward() {
        guard status == .playing, let currentDuration = current?.track.duration else { return }

        let newPlaybackPosition = player.currentTimeDuration + .seconds(5)
        if newPlaybackPosition < currentDuration {
            player.seek(to: newPlaybackPosition) { _ in
                self.updateInfoCenter()
            }
        }
    }

    public func seek(to percentage: Double, completion: ((Bool) -> Void)? = nil) {
        if let currentDuration = current?.track.duration {
            seek(to: .seconds(percentage * currentDuration.seconds), completion: completion)
        } else {
            completion?(false)
        }
    }
    
    public func seek(to duration: Duration, completion: ((Bool) -> Void)? = nil) {
        player.seek(to: duration) { isCompleted in
            completion?(isCompleted)
            self.updateInfoCenter()
        }
    }
    
    public func networkUpdated(_ endpoint: Endpoint) {
        network = endpoint.isInNetwork ? .local : .remote
    }
    
    
    
    // MARK: - Private Functions
    
    private func restoreSession() {
        guard current == nil else { return }
        
        if let data = UserDefaults.standard.data(for: .nowPlaying) {
            if let current = try? JSONDecoder().decode(NowPlaying.self, from: data) {
                self.current = current
                
                load([current.track] + current.next, play: false)
            }
        }
    }
    
    private func playerItemUpdate(_ item: AVPlayerItem?) {
        guard let current = current, !isInitialLoad else { return }
        
        if let asset = item?.asset, let track = assetMapping[asset] {
            self.current = NowPlaying(track, album: current.album, queue: current.queue)
        } else if current.next.isEmpty {
            player.pause()
            
            // Move to beginning of queue
            load(current.queue, play: false)
        }
        
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = self.current?.history.isNotEmpty == true
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = self.current?.next.isNotEmpty == true
        
        updateInfoCenter()
    }
    
    private func queue(_ track: Track) {
        do {
            if let asset = try emby.asset(for: track, network: network) {
                assetMapping[asset] = track
                
                let item = AVPlayerItem(asset: asset)
                if player.canInsert(item, after: nil) {
                    player.insert(item, after: nil)
                }
            }
        } catch {
            print(error)
        }
        
    }
    
    private func load(_ tracks: [Track], play: Bool = true) {
        player.removeAllItems()
        assetMapping.removeAll()
        
        isInitialLoad = false
        
        if play {
            self.play()
        }
        
        tracks.forEach(queue)
    }
    
    private func setupRemoteControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { _ in
            self.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { _ in
            self.pause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.seek(to: .seconds(event.positionTime))
            }
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { event in
            self.previous()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { event in
            self.next()
            return .success
        }
    }
    
    private func updateInfoCenter() {
        guard let track = current?.track else { return }

        if let imageURL = emby.imageURL(for: track) {
            let request = URLRequest(url: imageURL, cachePolicy: .returnCacheDataElseLoad)
            
            if let response = URLSession.shared.configuration.urlCache?.cachedResponse(for: request) {
                setInfoCenterData(track, imageData: response.data)
            } else {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    self.setInfoCenterData(track, imageData: data)
                }.resume()
            }
        } else {
            setInfoCenterData(track)
        }
    }
    
    private func setInfoCenterData(_ track: Track, imageData: Data? = nil) {
        var info: [String: Any] = [
            MPMediaItemPropertyArtist: track.artistsDescription,
            MPMediaItemPropertyTitle: track.name,
            MPMediaItemPropertyAlbumTitle: track.albumName,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentItem?.currentTime().seconds ?? 0,
            MPMediaItemPropertyPlaybackDuration: track.duration.seconds,
            MPNowPlayingInfoPropertyPlaybackRate: player.rate
        ]
        
        if let imageData = imageData {
            if #available(iOS 16, *) {
                if let image = UIImage(data: imageData) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    info[MPMediaItemPropertyArtwork] = artwork
                }
            } else if #available(macOS 13, *) {
                
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
