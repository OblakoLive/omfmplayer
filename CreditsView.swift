import SwiftUI

struct Contributor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: String
    let link: URL?
    let imageName: String?   // имя аватарки в Assets (опционально)
}

private let coreTeam: [Contributor] = [
    .init(name: "s", role: "owner", link: URL(string: "https://omfm.ru"), imageName: nil),
    .init(name: "gAlleb", role: "co-owner", link: URL(string: "https://github.com/galleb/nuxt-om"), imageName: nil),
    .init(name: "NAUTILUS", role: "iOS приложение", link: URL(string: "https://oblakolive.ru"), imageName: nil),
    .init(name: "Мы в IRC", role: "#omFM #usue at ircs://ircnet.ru:6689", link: nil, imageName: nil),
]

private let thanks: [Contributor] = [
    .init(name: "makarovvideo", role: "тестирование", link: nil, imageName: nil),
]

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.2)))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("omFM Radio")
                                .font(.title3).bold()
                            Text("v\(version) • build \(build)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Команда") {
                    ForEach(coreTeam) { c in
                        ContributorRow(c: c)     // ← добавили c:
                    }
                }

                if !thanks.isEmpty {
                    Section("Спасибо") {
                        ForEach(thanks) { c in
                            ContributorRow(c: c) // ← добавили c:
                        }
                    }
                }

                Section("Правовая информация") {
                    Link("Политика конфиденциальности", destination: URL(string: "https://omfm.ru/privacy")!)
                    Link("Условия использования", destination: URL(string: "https://omfm.ru/terms")!)
                    Text("Музыка и метаданные принадлежат соответствующим правообладателям.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("О приложении")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}

private struct ContributorRow: View {
    let c: Contributor
    var body: some View {
        HStack(spacing: 12) {
            if let imgName = c.imageName, let img = UIImage(named: imgName) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle().fill(.gray.opacity(0.2))
                    Image(systemName: "person.fill")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(c.name).font(.body)
                Text(c.role).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if let url = c.link {
                Link(destination: url) {
                    Image(systemName: "link")
                        .imageScale(.medium)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
