# Changelog

История заметных изменений проекта **omFMPlayer**.

## [Unreleased]

### Added

- Добавлена станция **Noir** с HLS-потоком `https://radio.omfm.ru/hls/noir/live.m3u8`.

### Changed

- Метаданные станции **Café de Paris** синхронизированы с актуальным описанием omFM.ru: `jazz, chanson, Parisian spirit`.
- README обновлён: теперь в списке приложения 8 станций, включая Noir.

## [2026-08-31]

### Fixed

- Исправлена конфигурация Bluetooth-аудио в `RadioPlayer.swift`: устаревший `AVAudioSession.CategoryOptions.allowBluetooth` заменён на актуальный `allowBluetoothHFP`.
- Убрано предупреждение Xcode о deprecated Bluetooth audio option.
- Поддержка AirPlay через `allowAirPlay` сохранена без изменений.
