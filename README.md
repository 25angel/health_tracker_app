# 🧠 HealthTracker App
Приложение для отслеживания здоровья, сна, пульса и медитации — с поддержкой Apple Watch.

## 📸 Скриншоты

<p float="left">
  <img src="screenshots/main_menu.jpg" width="200"/>
  <img src="screenshots/training_menu.png" width="200"/>
  <img src="screenshots/mood_notes.png" width="200"/>
  <img src="screenshots/foot_menu.png" width="200"/>
  <img src="screenshots/foot_detail.png" width="200"/>
  <img src="screenshots/meditation.png" width="200"/>
</p>

## 🚀 Функциональность

- 🔬 Измерение пульса в реальном времени через Apple Watch
- 💤 Отслеживание сна, шагов, калорий и активности
- 🍽 Уведомления о приёме пищи и рекомендации по питанию
- 🧘 Медитации с дыхательной анимацией и таймером
- 🎯 Постановка целей (например, шагов в день)
- 🔔 Уведомления о достижении целей (геймификация)
- 🛡 Система доверенного контакта (в экстренных ситуациях)

## 🛠 Технологии

- Flutter + Dart
- Firebase (Auth, Firestore, Storage)
- Apple HealthKit / Apple Watch integration

## 🛠 Технологии и инструменты

- **Flutter** — UI-фреймворк для кроссплатформенного мобильного интерфейса
- **Dart** — основной язык программирования
- **Firebase** — аутентификация, Firestore, Storage, уведомления
- **HealthKit** — интеграция с Apple Watch (пульс, сон, активность)
- **Пакет `health`** — обёртка для взаимодействия с Apple HealthKit
- **Provider** — управление состоянием приложения
- **Visual Studio Code** — среда разработки

## 📦 Установка

1. Клонируй репозиторий:

```bash
git clone https://github.com/25angel/healthtracker.git
cd healthtracker
```

2. Установи зависимости:

```bash
flutter pub get
```

3. Настрой Firebase:

- Создай проект на [https://console.firebase.google.com](https://console.firebase.google.com)
- Добавь Android- и iOS-приложения
- Скачай и помести:
  - `google-services.json` → `android/app/`
  - `GoogleService-Info.plist` → `ios/Runner/`

📌 Без этих файлов Firebase (аутентификация, база и storage) работать не будет.

4. Запусти приложение:

```bash
flutter run
```

> Убедись, что подключено устройство или эмулятор.

---