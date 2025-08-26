import SwiftUI
import AVFoundation

@main
struct omFMPlayerApp: App {
    init() { configureAudioSession() }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(RadioPlayer.shared)
        }
    }
}

private func configureAudioSession() {
    do {
        let s = AVAudioSession.sharedInstance()
        try s.setCategory(.playback, mode: .default, policy: .longFormAudio)
        try s.setActive(true)
    } catch {
        print("Audio session error:", error)
    }
}
