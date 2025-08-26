import SwiftUI

struct Station: Identifiable, Equatable {
    let id: String          // короткий слаг: "stream", "rock", ...
    let title: String
    let url: URL            // HLS .m3u8
    let subtitle: String
    let colors: [Color]
}

extension Station {
    static let all: [Station] = [
        .init(
            id: "stream",
            title: "omFM Main",
            url: URL(string: "https://hls.omfm.ru/omfm/stream.m3u8")!,
            subtitle: "meditative, mantras, instrumental",
            colors: [.purple.opacity(0.5), .black]
        ),
        .init(
            id: "rock",
            title: "Rock",
            url: URL(string: "https://radio.omfm.ru/hls/radio/live.m3u8")!,
            subtitle: "heavy stuff and more",
            colors: [.red.opacity(0.5), .black]
        ),
        .init(
            id: "coma",
            title: "Coma",
            url: URL(string: "https://radio.omfm.ru/hls/coma/live.m3u8")!,
            subtitle: "ambient, drone, field recordings",
            colors: [.teal.opacity(0.5), .black]
        ),
        .init(
            id: "terra",
            title: "Terra",
            url: URL(string: "https://radio.omfm.ru/hls/terra/live.m3u8")!,
            subtitle: "nature, world, calm",
            colors: [.green.opacity(0.5), .black]
        ),
        .init(
            id: "core",
            title: "Core",
            url: URL(string: "https://radio.omfm.ru/hls/core/live.m3u8")!,
            subtitle: "deathcore, metalcore, hardcore",
            colors: [.indigo.opacity(0.5), .black]
        ),
        .init(
            id: "chill",
            title: "Chill",
            url: URL(string: "https://radio.omfm.ru/hls/chill/live.m3u8")!,
            subtitle: "lofi, chill, relax",
            colors: [.blue.opacity(0.5), .black]
        ),
        .init(
            id: "cdp",
            title: "CDP",
            url: URL(string: "https://hls.omfm.ru/cdp/cdp.m3u8")!,
            subtitle: "classical deep pieces",
            colors: [.orange.opacity(0.5), .black]
        )
    ]
}

