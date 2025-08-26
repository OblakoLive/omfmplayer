import SwiftUI
import AVKit

// AirPlay кнопка (AVRoutePickerView)
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let v = AVRoutePickerView()
        v.prioritizesVideoDevices = false
        v.activeTintColor = .white
        v.tintColor = .white
        return v
    }
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

struct ContentView: View {
    @EnvironmentObject var radio: RadioPlayer
    @State private var showCredits = false

    // мапа имен картинок станций из Assets
    private func imageName(for station: Station) -> String? {
        switch station.id {
        case "stream": return "station_main"
        case "rock":   return "station_rock"
        case "coma":   return "station_coma"
        case "terra":  return "station_terra"
        case "core":   return "station_core"
        case "chill":  return "station_chill"
        case "cdp":    return "station_cdp"
        default:       return nil
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .black.opacity(0.9)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                // шапка: заголовок + AirPlay + кнопка "О приложении"
                HStack(spacing: 12) {
                    Text("omFM Radio")
                        .font(.title).bold()
                        .foregroundStyle(.white)
                    Spacer()
                    AirPlayButton()
                        .frame(width: 28, height: 28)

                    Button {
                        showCredits = true
                    } label: {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                            .foregroundStyle(.white)
                            .accessibilityLabel(Text("О приложении"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // список станций
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Station.all) { st in
                            StationCard(
                                station: st,
                                active: st == radio.currentStation,
                                imageName: imageName(for: st)
                            )
                            .onTapGesture { radio.switchTo(st) }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // крупная обложка по центру
                if let img = radio.artwork {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 340)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                }

                // бегущая строка артист — трек
                MarqueeText(
                    text: radio.nowPlaying.isEmpty ? radio.currentStation.title : radio.nowPlaying,
                    font: .subheadline,
                    speed: 45,
                    gap: 40,
                    run: radio.isPlaying
                )
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
                .padding(.horizontal, 16)

                Spacer(minLength: 8)

                // мини-плеер снизу
                MiniPlayerView()
                    .environmentObject(radio)
            }
        }
        // окно с кредами
        .sheet(isPresented: $showCredits) {
            CreditsView()
        }
    }
}

// карточка станции
struct StationCard: View {
    let station: Station
    let active: Bool
    let imageName: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let name = imageName, let img = UIImage(named: name) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 240, height: 140)
                    .clipped()
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.55), .clear],
                                       startPoint: .bottom, endPoint: .top)
                    )
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .frame(width: 240, height: 140)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(station.title)
                    .font(.headline).bold()
                    .foregroundStyle(.white)
                Text(station.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(active ? .blue : .white.opacity(0.15), lineWidth: active ? 2 : 1)
        )
        .cornerRadius(18)
        .shadow(radius: active ? 8 : 0, y: active ? 4 : 0)
    }
}

// мини-плеер
struct MiniPlayerView: View {
    @EnvironmentObject var radio: RadioPlayer

    private func prev() { radio.prevStation() }
    private func next() { radio.nextStation() }

    var body: some View {
        HStack(spacing: 12) {
            if let img = radio.artwork {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.15))
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(radio.nowPlaying.isEmpty ? radio.currentStation.title : radio.nowPlaying)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                Text(radio.currentStation.title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Button(action: prev) {
                Image(systemName: "backward.end.fill").font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)

            Button(action: { radio.togglePlay() }) {
                Image(systemName: radio.isPlaying ? "pause.fill" : "play.fill").font(.title3).bold()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)

            Button(action: next) {
                Image(systemName: "forward.end.fill").font(.title3)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

