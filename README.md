# �� HealthTracker App

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)](https://flutter.dev/) [![Firebase](https://img.shields.io/badge/Firebase-Enabled-yellow?logo=firebase)](https://firebase.google.com/) ![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Web-lightgrey) ![Авторское право](https://img.shields.io/badge/%D0%90%D0%B2%D1%82%D0%BE%D1%80%D1%81%D0%BA%D0%BE%D0%B5%20%D0%BF%D1%80%D0%B0%D0%B2%D0%BE-%D0%B7%D0%B0%D1%89%D0%B8%D1%89%D0%B5%D0%BD%D0%BE-blue)

> **RU:** Приложение для отслеживания здоровья, сна, пульса и медитации — с поддержкой Apple Watch.
> 
> **EN:** Health, sleep, heart rate & meditation tracker app — with Apple Watch support.

---

## 📸 Скриншоты / Screenshots

<table>
  <tr>
    <td align="center">
      <a href="screenshots/main_menu.jpg"><img src="screenshots/main_menu.jpg" width="180"/></a><br/>
      Главный экран<br/>Main menu
    </td>
    <td align="center">
      <a href="screenshots/training_menu.jpg"><img src="screenshots/training_menu.jpg" width="180"/></a><br/>
      Тренировки<br/>Training
    </td>
    <td align="center">
      <a href="screenshots/mood_notes.jpg"><img src="screenshots/mood_notes.jpg" width="180"/></a><br/>
      Настроение и заметки<br/>Mood & Notes
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="screenshots/foot_menu.jpg"><img src="screenshots/foot_menu.jpg" width="180"/></a><br/>
      Питание<br/>Food
    </td>
    <td align="center">
      <a href="screenshots/foot_detail.jpg"><img src="screenshots/foot_detail.jpg" width="180"/></a><br/>
      Детали питания<br/>Food Detail
    </td>
    <td align="center">
      <a href="screenshots/meditation.jpg"><img src="screenshots/meditation.jpg" width="180"/></a><br/>
      Медитация<br/>Meditation
    </td>
  </tr>
</table>

---

## 🚀 Функциональность / Features

- 🔬 Измерение пульса в реальном времени через Apple Watch / Real-time heart rate via Apple Watch
- 💤 Отслеживание сна, шагов, калорий и активности / Sleep, steps, calories & activity tracking
- 🍽 Уведомления о приёме пищи и рекомендации по питанию / Meal reminders & nutrition tips
- 🧘 Медитации с дыхательной анимацией и таймером / Meditation with breathing animation & timer
- 🎯 Постановка целей (например, шагов в день) / Goal setting (e.g. daily steps)
- 🔔 Уведомления о достижении целей (геймификация) / Goal achievement notifications (gamification)
- 🛡 Система доверенного контакта (в экстренных ситуациях) / Trusted contact system (emergency)

---

## 🛠 Технологии / Tech Stack

- **Flutter** — UI-фреймворк для кроссплатформенного мобильного интерфейса
- **Dart** — основной язык программирования
- **Firebase** — аутентификация, Firestore, Storage, уведомления
- **HealthKit** — интеграция с Apple Watch (пульс, сон, активность)
- **Пакет `health`** — обёртка для взаимодействия с Apple HealthKit
- **Provider** — управление состоянием приложения
- **Visual Studio Code** — среда разработки

---

## 📦 Установка / Getting Started

1. **Клонируй репозиторий / Clone the repo:**

```bash
git clone https://github.com/25angel/health_tracker_app.git
cd health_tracker_app
```

2. **Установи зависимости / Install dependencies:**

```bash
flutter pub get
```

3. **Настрой Firebase / Configure Firebase:**
- Создай проект на [Firebase Console](https://console.firebase.google.com)
- Добавь Android- и iOS-приложения
- Скачай и помести:
  - `google-services.json` → `android/app/`
  - `GoogleService-Info.plist` → `ios/Runner/`

📌 Без этих файлов Firebase (аутентификация, база и storage) работать не будет.

4. **Запусти приложение / Run the app:**

```bash
flutter run
```

> Убедись, что подключено устройство или эмулятор. / Make sure a device or emulator is connected.

---

## 🎬 Demo

<!-- Optionally add a GIF or video link here -->
<!-- ![Demo](demo/demo.gif) -->

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

Проект защищён авторским свидетельством. Все права защищены.

---

## 👤 Author / Contacts

- Telegram: [@svnteenmart](https://t.me/svnteenmart)
- GitHub: [25angel](https://github.com/25angel)