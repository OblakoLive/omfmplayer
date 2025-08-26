import UIKit

struct ArtworkService {
    static func findArtwork(artist: String, title: String) async -> UIImage? {
        let q = "\(artist) \(title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(q)&entity=song&limit=1") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let arr = json["results"] as? [[String: Any]],
                  let first = arr.first,
                  var art = first["artworkUrl100"] as? String
            else { return nil }
            art = art.replacingOccurrences(of: "100x100", with: "600x600")
            guard let imgURL = URL(string: art) else { return nil }
            let (imgData, _) = try await URLSession.shared.data(from: imgURL)
            return UIImage(data: imgData)
        } catch { return nil }
    }
}
