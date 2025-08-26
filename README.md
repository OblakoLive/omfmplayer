````markdown
# omFMPlayer iOS

Нативный iOS-плеер для HLS-радио omFM. SwiftUI, AVPlayer, iOS 15+.
Работает в фоне, показывает артист — трек и обложку, поддерживает AirPlay и мини-плеер.

## Быстрый старт

```bash
git clone https://github.com/Oblakolive/omfmplayer.git
cd omfmplayer
open omFMPlayer.xcodeproj
````

Дальше в Xcode:

1. Открой Target → **Signing & Capabilities** и выбери свою **Team**.
2. Поменяй **Bundle Identifier** на уникальный (например `com.yourname.omfmplayer`).
3. Убедись, что включён **Background Modes → Audio, AirPlay, and Picture in Picture**.
4. Жми ▶︎ на симулятор или на устройство.

> Нет платной подписки? Тоже ок: выбери свою Team с бесплатным Apple ID — приложение поставится на устройство, но подпись придётся обновлять раз в 7 дней.

## Что внутри

* **SwiftUI** интерфейс, мини-плеер снизу.
* **AVPlayer** с HLS-потоками.
* **Now Playing** через `MPNowPlayingInfoCenter`: артист — трек и тайл музыки.
* **Метаданные** читаются из потока; если прилетает одна строка, парсим в формат «Артист — Трек».
* **Обложка**: берём из стрима, если есть; иначе ищем по «артист + трек» и подставляем.
* **AirPlay**: системная кнопка через `MPVolumeView`.

## Поддерживаемые iOS-версии и устройства

* Минимум **iOS 15.0** (реально с iPhone 6s и новее).
* Симуляторы: iPhone 8 → iPhone 16 Pro Max.
* CarPlay появится, когда Apple выдаст entitlement (см. ниже).

## Стримы

Адреса редактируются в `Station.swift`. Сейчас так:

```swift
enum Station: CaseIterable {
    case stream, rock, coma, terra, core, chill, cdp

    var url: URL {
        switch self {
        case .stream: return URL(string: "https://hls.omfm.ru/omfm/stream.m3u8")!
        case .rock:   return URL(string: "https://radio.omfm.ru/hls/radio/live.m3u8")!
        case .coma:   return URL(string: "https://radio.omfm.ru/hls/coma/live.m3u8")!
        case .terra:  return URL(string: "https://radio.omfm.ru/hls/terra/live.m3u8")!
        case .core:   return URL(string: "https://radio.omfm.ru/hls/core/live.m3u8")!
        case .chill:  return URL(string: "https://radio.omfm.ru/hls/chill/live.m3u8")!
        case .cdp:    return URL(string: "https://hls.omfm.ru/cdp/cdp.m3u8")!
        }
    }
}
```

## Картинки станций

Лежат в `Assets.xcassets`, имена:

* `station_main`
* `station_rock`
* `station_coma`
* `station_terra`
* `station_core`
* `station_chill`
* `station_cdp`

Хочешь заменить — просто перетащи новые JPG/PNG с такими же именами в соответствующие image set’ы.

## Обложка трека

Логика в `RadioPlayer.swift` и `ArtworkService.swift`:

1. Пытаемся вытащить картинку из метаданных потока (ID3/iTunes/QuickTime).
2. Если нет — берём «артист — трек» и ищем обложку (например, iTunes Search).
3. Кладём в `@Published var artwork: UIImage?`, UI подхватывает и показывает.

## AirPlay

Кнопка AirPlay — это обёртка над `MPVolumeView`. В `ContentView.swift` есть `AirPlayButton` (UIViewRepresentable). Ничего настраивать не нужно.

## Фон и гарнитуры

Работает из коробки, если включён **Background Modes → Audio…**.
Системные кнопки «пауза/плей/следующий» тоже поддерживаются через `MPRemoteCommandCenter`.

## CarPlay (планы)

* Включи capability **CarPlay Audio** (entitlement выдаёт Apple по запросу).
* Реализуй `CPNowPlayingTemplate` (минимум), опционально `CPListTemplate` для списка станций.
* Тестировать можно в iOS Simulator → Features → External Displays → CarPlay.

Без entitlement приложение в машине не появится — это нормально.

## Локализация

Основная локаль — **ru**. Тексты UI в `ContentView.swift` можно вынести в Localizable.strings, если понадобится.

## Как собрать .ipa (опционально)

Product → Archive → Distribute App → **Development** → Export.
.ipa можно подписать и поставить через AltStore/Sideloadly. Для широкой аудитории лучше TestFlight/App Store.

## Тестирование и релиз

* **TestFlight** и **App Store** требуют платный Apple Developer Program.
* App Store Connect: добавь скриншоты, иконку 1024×1024, политику конфиденциальности и права на контент.

## Частые вопросы

* **Не играет в фоне** — проверь Background Modes и что плеер не освобождается (RadioPlayer — singleton/ObservableObject в окружении).
* **Нет «артист — трек»** — значит поток не шлёт метаданные или шлёт в нестандартном виде.
* **Иконка не меняется на тёмную** — цветные/тёмные иконки управляются настройками домашнего экрана iOS 18, не системной темой.

## Скрипт для репо

Команды на всякий случай:

```bash
git add .
git commit -m "Update"
git push
```

## Лицензия

MIT — см. файл `LICENSE`.

## Контакты и кредиты

* Автор/координатор: **oblakolive**
* Вкладчики/дизайн/музыка — см. экран **Credits** внутри приложения.

```
