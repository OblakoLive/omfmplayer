import SwiftUI
import Combine

/// Бегущая строка. Скроллит только если текст не помещается.
/// speed — пикселей в секунду. run=false — пауза прокрутки.
public struct MarqueeText: View {
    public let text: String
    public let font: Font
    public let speed: CGFloat
    public let gap: CGFloat
    public let run: Bool

    @State private var textWidth: CGFloat = 0
    @State private var offsetX: CGFloat = 0

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    public init(text: String,
                font: Font,
                speed: CGFloat = 30,
                gap: CGFloat = 36,
                run: Bool = true) {
        self.text = text
        self.font = font
        self.speed = speed
        self.gap = gap
        self.run = run
    }

    public var body: some View {
        GeometryReader { geo in
            let needScroll = textWidth > geo.size.width

            ZStack(alignment: .leading) {
                if needScroll {
                    HStack(spacing: gap) {
                        label.background(WidthReader(width: $textWidth))
                        label
                    }
                    .offset(x: offsetX)
                    .clipped()
                    .onReceive(timer) { _ in
                        guard run, textWidth > 0 else { return }
                        let step = speed / 60.0
                        let distance = textWidth + gap
                        offsetX -= step
                        if -offsetX >= distance { offsetX = 0 }
                    }
                    // когда пришёл другой текст — начинаем с нуля
                    .onReceive(Just(text)) { _ in
                        offsetX = 0
                    }
                } else {
                    label
                        .lineLimit(1)
                        .background(WidthReader(width: $textWidth))
                }
            }
        }
        .frame(height: 20)
    }

    private var label: some View {
        Text(text)
            .font(font)
            .lineLimit(1)
            .truncationMode(.tail)
            .allowsTightening(true)
            .foregroundColor(.white.opacity(0.7))
    }
}

// измеряем ширину текста
private struct WidthReader: View {
    @Binding var width: CGFloat
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: WidthKey.self, value: proxy.size.width)
        }
        .onPreferenceChange(WidthKey.self) { width = $0 }
    }
}
private struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
