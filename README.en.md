# omFMPlayer iOS

A native iOS player for omFM HLS radio. Built with SwiftUI and AVPlayer, targeting iOS 15+.
It supports background playback, artist/track metadata, artwork, AirPlay, and a mini-player.

## Quick start

```bash
git clone https://github.com/Oblakolive/omfmplayer.git
cd omfmplayer
open omFMPlayer.xcodeproj
```

Then in Xcode:

1. Open Target → **Signing & Capabilities** and select your **Team**.
2. Change the **Bundle Identifier** to a unique value (for example `com.yourname.omfmplayer`).
3. Make sure **Background Modes → Audio, AirPlay, and Picture in Picture** is enabled.
4. Press ▶︎ to run on a simulator or a connected device.

> A paid Apple Developer subscription is not required for local testing with a free Apple ID, but the development signature must be renewed periodically.

## What's inside

* **SwiftUI** interface with a bottom mini-player.
* **AVPlayer** for HLS streams.
* **Now Playing** metadata through `MPNowPlayingInfoCenter`.
* **Metadata parsing** from the stream, including artist — track formatting when needed.
* **Artwork** from stream metadata or an external search when available.
* **AirPlay** through the system `MPVolumeView` button.

## Supported iOS versions and devices

* Minimum **iOS 15.0**.
* iPhone and iOS Simulator targets supported by the project configuration.
* CarPlay support is planned and requires the appropriate Apple entitlement.

## Streams

Stream URLs are configured in `Station.swift`.

## Station artwork

Station images are stored in `Assets.xcassets` using the corresponding image-set names. Replace the images while keeping the existing names if you want to change the station artwork.

## Track artwork

The artwork logic is implemented in `RadioPlayer.swift` and `ArtworkService.swift`:

1. Try to extract artwork from stream metadata (ID3/iTunes/QuickTime).
2. If unavailable, use artist and track information to search for artwork when supported.
3. Publish the resulting image so the UI can display it.

## AirPlay

The AirPlay button wraps `MPVolumeView` in `ContentView.swift`. No additional configuration is required beyond the app's audio capabilities.

## Background playback and headsets

Background playback requires the **Background Modes → Audio** capability. System playback controls are handled through `MPRemoteCommandCenter`.

## CarPlay (planned)

CarPlay integration requires an Apple-issued entitlement. The intended implementation can use `CPNowPlayingTemplate` and, optionally, `CPListTemplate` for station selection.

## Localization

The primary locale is **Russian (ru)**. UI strings currently live in the SwiftUI code and can be moved to `Localizable.strings` if additional localization is needed.

## Building an .ipa (optional)

Use **Product → Archive → Distribute App → Development → Export** in Xcode.
For wider distribution, use TestFlight or the App Store through App Store Connect.

## Testing and release

* **TestFlight** and **App Store** distribution require membership in the Apple Developer Program.
* App Store Connect requires the appropriate app metadata, screenshots, icon assets, privacy information, and rights to distributed content.

## Troubleshooting

* **Background playback does not work** — check Background Modes and make sure the player object remains alive for the lifetime of playback.
* **Artist — track metadata is missing** — the stream may not provide metadata or may use an unsupported format.
* **App icon appearance** — icon presentation can also be affected by iOS Home Screen appearance settings.

## Repository commands

```bash
git add .
git commit -m "Update"
git push
```

## License

MIT — see `LICENSE`.

## Credits and contact

* Author/coordinator: **oblakolive**
* Contributors, design, and music credits are listed in the **Credits** screen inside the app.

## Documentation

* [Русская версия README](README.md)
* [Changelog](CHANGELOG.md)
