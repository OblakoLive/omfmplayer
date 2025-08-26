import Foundation
import AVFoundation
import MediaPlayer
import UIKit

// Радиоплеер: HLS, фон, Now Playing, метаданные (artist/title + artwork)
// Ловим метаданные через MetadataCollector и MetadataOutput. iOS 15+.
final class RadioPlayer: NSObject, ObservableObject {

    static let shared = RadioPlayer()

    // MARK: Internals
    private let player = AVPlayer()
    private var metadataCollector: AVPlayerItemMetadataCollector?
    private var metadataOutput: AVPlayerItemMetadataOutput?

    private let defaults = UserDefaults.standard
    private let lastStationKey = "lastStationID"

    // анти-спам поиска обложек
    private var lastArtworkQuery: String?
    private var lastArtworkAt: Date?

    // MARK: State
    @Published var isPlaying = false
    @Published var currentStation: Station = .all.first!
    @Published var nowPlaying: String = ""
    @Published var artwork: UIImage?

    // MARK: Init
    override init() {
        super.init()

        if let savedID = defaults.string(forKey: lastStationKey),
           let st = Station.all.first(where: { $0.id == savedID }) {
            currentStation = st
        }

        artwork = placeholderArtwork(for: currentStation.id)

        prepareItem(url: currentStation.url)
        setupRemoteCommands()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        updateNowPlayingCenter()
    }

    // MARK: Public
    func togglePlay() { isPlaying ? pause() : play() }

    func play() {
        do {
            let s = AVAudioSession.sharedInstance()
            try s.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try s.setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
        player.automaticallyWaitsToMinimizeStalling = true
        player.play()
        isPlaying = true
        updateNowPlayingCenter()
    }

    func pause() {
        player.pause()
        isPlaying = false
        updateNowPlayingCenter()
    }

    func switchTo(_ station: Station) {
        currentStation = station
        defaults.set(station.id, forKey: lastStationKey)

        artwork = placeholderArtwork(for: station.id)      // временный фон
        lastArtworkQuery = nil                             // сбросим анти-спам

        prepareItem(url: station.url)
        if isPlaying { player.play() }
        updateNowPlayingCenter()
    }

    func nextStation() {
        guard let i = Station.all.firstIndex(of: currentStation) else { return }
        switchTo(Station.all[(i + 1) % Station.all.count])
    }

    func prevStation() {
        guard let i = Station.all.firstIndex(of: currentStation) else { return }
        switchTo(Station.all[(i - 1 + Station.all.count) % Station.all.count])
    }

    // MARK: Player setup
    private func prepareItem(url: URL) {
        let asset = AVURLAsset(url: url)     // HLS m3u8
        let item  = AVPlayerItem(asset: asset)
        item.preferredForwardBufferDuration = 3

        if let old = player.currentItem {
            if let c = metadataCollector { old.remove(c) }
            if let o = metadataOutput   { old.remove(o) }
        }

        // MetadataCollector
        let collector = AVPlayerItemMetadataCollector(identifiers: nil, classifyingLabels: nil)
        collector.setDelegate(self, queue: .main)
        item.add(collector)
        metadataCollector = collector

        // MetadataOutput (часто HLS ID3 летит сюда)
        let output = AVPlayerItemMetadataOutput(identifiers: nil)
        output.setDelegate(self, queue: .main)
        item.add(output)
        metadataOutput = output

        NotificationCenter.default.addObserver(self, selector: #selector(handleStall),
                                               name: .AVPlayerItemPlaybackStalled, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFail),
                                               name: .AVPlayerItemFailedToPlayToEndTime, object: item)

        player.replaceCurrentItem(with: item)
    }

    private func setupRemoteCommands() {
        let cc = MPRemoteCommandCenter.shared()
        cc.playCommand.isEnabled = true
        cc.pauseCommand.isEnabled = true
        cc.togglePlayPauseCommand.isEnabled = true

        cc.playCommand.addTarget { [weak self] _ in self?.play();  return .success }
        cc.pauseCommand.addTarget { [weak self] _ in self?.pause(); return .success }
        cc.togglePlayPauseCommand.addTarget { [weak self] _ in self?.togglePlay(); return .success }
    }

    // MARK: Now Playing
    private func updateNowPlayingCenter(artist: String? = nil, title: String? = nil) {
        var info: [String: Any] = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]

        if let a = artist, let t = title, !a.isEmpty, !t.isEmpty {
            nowPlaying = "\(a) — \(t)"
            info[MPMediaItemPropertyArtist] = a
            info[MPMediaItemPropertyTitle]  = t
        } else if let t = title, !t.isEmpty {
            nowPlaying = t
            info[MPMediaItemPropertyTitle] = t
        } else {
            nowPlaying = currentStation.title
            info[MPMediaItemPropertyTitle] = currentStation.title
        }

        if let img = artwork {
            let art = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
            info[MPMediaItemPropertyArtwork] = art
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func setArtworkAndRefresh(_ img: UIImage) {
        artwork = img
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        let art = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
        info[MPMediaItemPropertyArtwork] = art
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: Metadata helpers
    private func parseArtistTitle(from text: String) -> (artist: String?, title: String?) {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: " – ", with: " - ")
             .replacingOccurrences(of: " — ", with: " - ")
        if let r = s.range(of: " - ") {
            let a = String(s[..<r.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let t = String(s[r.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return (a.isEmpty ? nil : a, t.isEmpty ? nil : t)
        }
        return (nil, s.isEmpty ? nil : s)
    }

    // Универсальный поиск по строке (а не только по паре a+t)
    private func fetchArtwork(query: String) async -> UIImage? {
        guard !query.isEmpty else { return nil }

        // анти-спам: та же строка чаще, чем раз в 20 сек — игнор
        if let lastQ = lastArtworkQuery, lastQ == query,
           let lastAt = lastArtworkAt, Date().timeIntervalSince(lastAt) < 20 {
            return nil
        }
        lastArtworkQuery = query
        lastArtworkAt = Date()

        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(q)&entity=song&limit=1") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let arr  = json["results"] as? [[String: Any]],
                  let first = arr.first,
                  var artURL = first["artworkUrl100"] as? String else { return nil }
            artURL = artURL.replacingOccurrences(of: "100x100", with: "600x600")
            guard let imgURL = URL(string: artURL) else { return nil }
            let (imgData, _) = try await URLSession.shared.data(from: imgURL)
            return UIImage(data: imgData)
        } catch {
            return nil
        }
    }

    private func placeholderArtwork(for id: String) -> UIImage? {
        switch id {
        case "stream": return UIImage(named: "station_main")
        case "rock":   return UIImage(named: "station_rock")
        case "coma":   return UIImage(named: "station_coma")
        case "core":   return UIImage(named: "station_core")
        case "terra":  return UIImage(named: "station_terra")
        case "chill":  return UIImage(named: "station_chill")
        case "cdp":    return UIImage(named: "station_cdp")
        default:       return nil
        }
    }

    // MARK: Interruptions & stalls
    @objc private func handleAudioInterruption(_ n: Notification) {
        guard let info = n.userInfo,
              let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        if type == .began {
            pause()
        } else if type == .ended, isPlaying {
            player.play()
        }
    }

    @objc private func handleStall() {
        if isPlaying { player.play() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.reconnectIfNeeded()
        }
    }

    @objc private func handleFail() { reconnectIfNeeded() }

    private func reconnectIfNeeded() {
        guard isPlaying else { return }
        prepareItem(url: currentStation.url)
        player.play()
    }
}

// MARK: Общая обработка метаданных из Collector/Output
private extension RadioPlayer {
    func processMetadataItems(_ items: [AVMetadataItem]) {
        Task { @MainActor in
            var artist: String?
            var title:  String?
            var anyText: String?
            var gotArtwork = false

            for item in items {
                if #available(iOS 16.0, *) {
                    // artwork из потока
                    if let id = item.identifier,
                       id == .id3MetadataAttachedPicture ||
                       id == .quickTimeMetadataArtwork ||
                       id == .commonIdentifierArtwork {

                        if let data = try? await item.load(.dataValue),
                           let img  = UIImage(data: data) {
                            self.setArtworkAndRefresh(img)
                            gotArtwork = true
                            continue
                        }
                        if let data = (try? await item.load(.value)) as? Data,
                           let img  = UIImage(data: data) {
                            self.setArtworkAndRefresh(img)
                            gotArtwork = true
                            continue
                        }
                    }

                    // текст
                    if let s = try? await item.load(.stringValue), !s.isEmpty {
                        anyText = s
                        if let id = item.identifier {
                            switch id {
                            case .id3MetadataLeadPerformer, .quickTimeMetadataArtist, .iTunesMetadataArtist, .commonIdentifierArtist:
                                artist = s; continue
                            case .id3MetadataTitleDescription, .iTunesMetadataSongName, .quickTimeMetadataTitle, .commonIdentifierTitle:
                                title  = s; continue
                            default: break
                            }
                        }
                        let p = self.parseArtistTitle(from: s)
                        if artist == nil { artist = p.artist }
                        if title  == nil { title  = p.title  }
                    }

                } else {
                    // iOS 15-
                    if let id = item.identifier,
                       (id == .id3MetadataAttachedPicture ||
                        id == .quickTimeMetadataArtwork ||
                        id == .commonIdentifierArtwork),
                       let data = item.dataValue ?? (item.value as? Data),
                       let img  = UIImage(data: data) {
                        self.setArtworkAndRefresh(img)
                        gotArtwork = true
                        continue
                    }

                    if let s = item.stringValue, !s.isEmpty {
                        anyText = s
                        if let id = item.identifier {
                            switch id {
                            case .id3MetadataLeadPerformer, .quickTimeMetadataArtist, .iTunesMetadataArtist, .commonIdentifierArtist:
                                artist = s
                            case .id3MetadataTitleDescription, .iTunesMetadataSongName, .quickTimeMetadataTitle, .commonIdentifierTitle:
                                title  = s
                            default:
                                let p = self.parseArtistTitle(from: s)
                                if artist == nil { artist = p.artist }
                                if title  == nil { title  = p.title  }
                            }
                        }
                    }
                }
            }

            // Обновим текст
            self.updateNowPlayingCenter(artist: artist, title: title)

            // Нет картинки из потока — ищем по лучшему запросу
            if !gotArtwork {
                let query: String? =
                    (artist != nil && title != nil) ? "\(artist!) \(title!)" :
                    title ?? artist ?? anyText

                if let q = query, let img = await self.fetchArtwork(query: q) {
                    self.setArtworkAndRefresh(img)
                }
            }
        }
    }
}

// MARK: Delegates
extension RadioPlayer: AVPlayerItemMetadataCollectorPushDelegate {
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                           didCollect metadataGroups: [AVDateRangeMetadataGroup],
                           indexesOfNewGroups: IndexSet,
                           indexesOfModifiedGroups: IndexSet) {
        for g in metadataGroups { processMetadataItems(g.items) }
    }
}

extension RadioPlayer: AVPlayerItemMetadataOutputPushDelegate {
    func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                        didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                        from playerItemTrack: AVPlayerItemTrack?) {
        for g in groups { processMetadataItems(g.items) }
    }
}

