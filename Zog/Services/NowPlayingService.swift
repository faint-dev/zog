import AppKit
import Combine
import Foundation

/// Now Playing via MediaRemote private framework (same approach many
/// SketchyBar media plugins use). Falls back gracefully if unavailable.
final class NowPlayingService: ObservableObject {
    struct Track: Equatable {
        var title: String
        var artist: String
        var artwork: NSImage?
        var isPlaying: Bool
    }

    @Published private(set) var track: Track?
    @Published private(set) var isAvailable: Bool = false

    private var timer: Timer?
    private var mediaRemote: MediaRemoteBridge?

    func start() {
        mediaRemote = MediaRemoteBridge()
        isAvailable = mediaRemote?.isLoaded == true
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func playPause() { mediaRemote?.togglePlayPause() }
    func next() { mediaRemote?.next() }
    func previous() { mediaRemote?.previous() }

    private func refresh() {
        mediaRemote?.fetchNowPlaying { [weak self] info in
            DispatchQueue.main.async {
                guard let info else {
                    self?.track = nil
                    return
                }
                self?.track = Track(
                    title: info.title.isEmpty ? "Not Playing" : info.title,
                    artist: info.artist,
                    artwork: info.artwork,
                    isPlaying: info.isPlaying
                )
            }
        }
    }
}

// MARK: - MediaRemote bridge

private struct MediaInfo {
    var title: String
    var artist: String
    var artwork: NSImage?
    var isPlaying: Bool
}

/// Thin dynamic loader around the private MediaRemote framework.
private final class MediaRemoteBridge {
    private typealias GetNowPlayingInfo = @convention(c) (
        DispatchQueue,
        @escaping ([String: Any]?) -> Void
    ) -> Void

    private typealias SendCommand = @convention(c) (
        UInt32,
        [String: Any]?,
        DispatchQueue,
        ((Bool) -> Void)?
    ) -> Void

    private var getInfo: GetNowPlayingInfo?
    private var sendCommand: SendCommand?
    private(set) var isLoaded: Bool = false

    // Command codes from MediaRemote
    private let playPauseCommand: UInt32 = 2
    private let nextCommand: UInt32 = 4
    private let previousCommand: UInt32 = 5

    init() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"
        guard let handle = dlopen(path, RTLD_LAZY) else { return }

        if let sym = dlsym(handle, "MRMediaRemoteGetNowPlayingInfo") {
            getInfo = unsafeBitCast(sym, to: GetNowPlayingInfo.self)
        }
        if let sym = dlsym(handle, "MRMediaRemoteSendCommand") {
            sendCommand = unsafeBitCast(sym, to: SendCommand.self)
        }
        isLoaded = getInfo != nil
    }

    func fetchNowPlaying(completion: @escaping (MediaInfo?) -> Void) {
        guard let getInfo else {
            completion(nil)
            return
        }
        getInfo(DispatchQueue.global(qos: .utility)) { dict in
            guard let dict else {
                completion(nil)
                return
            }
            let title = dict["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
            let artist = dict["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
            var artwork: NSImage?
            if let data = dict["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                artwork = NSImage(data: data)
            }
            let rate = dict["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double ?? 0
            completion(MediaInfo(title: title, artist: artist, artwork: artwork, isPlaying: rate > 0))
        }
    }

    func togglePlayPause() {
        sendCommand?(playPauseCommand, nil, .main, nil)
    }

    func next() {
        sendCommand?(nextCommand, nil, .main, nil)
    }

    func previous() {
        sendCommand?(previousCommand, nil, .main, nil)
    }
}
