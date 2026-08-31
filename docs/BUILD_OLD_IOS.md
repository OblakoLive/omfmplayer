# Запуск на iPhone 6s и других устройствах с iOS 15

Коротко: Xcode 16 считает iOS 15 устройствами только для сборки, запуск из IDE не поддержан.  
Поэтому используем Xcode 15 или ставим .ipa.

## Вариант A. Рекомендовано — Xcode 15.x

1. Скачай Xcode 15.x на странице Apple Developer Downloads.
2. Положи рядом с Xcode 16 и переименуй, например: `Xcode15.app`.
3. Открой проект в Xcode 15.
4. Выставь Deployment Target = **iOS 15.0**:
   - Target → **omFMPlayer** → вкладка **General** → **Deployment Info** → iOS 15.0
5. В разделе **Signing & Capabilities** выбери свой **Team**.
6. Подключи iPhone 6s к Mac, на телефоне включи **Режим разработчика** и **Доверять этому компьютеру**.
7. В схеме выбери подключённый iPhone 6s и жми **Run**.

## Вариант B. Установка .ipa без отладки

1. В Xcode **Product → Archive**.
2. **Distribute App** → **Development** или **Ad-hoc** → подпиши → получи `.ipa`.
3. Открой **Apple Configurator** → подключи 6s → перетащи `.ipa` на устройство.

## Вариант C. Хак с DeviceSupport (не гарантируется)

1. Из `Xcode15.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/15.x`
   скопируй папку `15.x` в  
   `Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/`.
2. Перезапусти Xcode 16 и проверь устройство. Если не помогло — используй Вариант A.

## Чеклист

- Deployment Target проекта ≤ версия iOS на устройстве (для 6s — 15.0)
- Архитектура: **Standard (arm64)**
- В схеме выбрано реальное устройство, а не Any iOS Device
- В **Signing** выбран твой Team, профили подтянулись
