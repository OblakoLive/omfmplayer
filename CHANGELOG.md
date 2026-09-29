# Changelog

История заметных изменений проекта **omFMPlayer**.

## [1.2.0] - 2026-09-29

### Added

- Добавлена станция **386 by xff** (EBM, Synthpop, Dark Ambient) с HLS-потоком `https://hls.386.su/386/386.m3u8` и картинкой `station_386`.
- Обложки станций Ashes, Noir и 386 теперь показываются на экране блокировки.

### Changed

- Поток станции **Noir** переведён на `https://hls.386.su/noir/noir.m3u8`, как на omFM.ru.
- Версия приложения: 1.2.0 (build 3).

## [1.1.0] - 2026-09-01

### Added

- Добавлена станция **Ashes** с HLS-потоком `https://radio.omfm.ru/hls/ashes/live.m3u8`.
- Добавлена станция **Noir** с HLS-потоком `https://radio.omfm.ru/hls/noir/live.m3u8`.

### Changed

- Метаданные станции **Café de Paris** синхронизированы с актуальным описанием omFM.ru: `jazz, chanson, Parisian spirit`.
- README обновлён: список приложения синхронизирован с актуальными станциями omFM.ru.

## [2026-08-31]

### Fixed

- Исправлена конфигурация Bluetooth-аудио в `RadioPlayer.swift`: устаревший `AVAudioSession.CategoryOptions.allowBluetooth` заменён на актуальный `allowBluetoothHFP`.
- Убрано предупреждение Xcode о deprecated Bluetooth audio option.
- Поддержка AirPlay через `allowAirPlay` сохранена без изменений.
