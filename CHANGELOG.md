# Changelog

История заметных изменений проекта **omFMPlayer**.

## [Unreleased]

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
