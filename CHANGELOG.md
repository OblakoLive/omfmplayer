# Changelog

История заметных изменений проекта **omFMPlayer**.

## [Unreleased]

Здесь будут собираться изменения, которые войдут в следующий релиз.

## [2026-08-31]

### Fixed

- Исправлена конфигурация Bluetooth-аудио в `RadioPlayer.swift`: устаревший `AVAudioSession.CategoryOptions.allowBluetooth` заменён на актуальный `allowBluetoothHFP`.
- Убрано предупреждение Xcode о deprecated Bluetooth audio option.
- Поддержка AirPlay через `allowAirPlay` сохранена без изменений.
