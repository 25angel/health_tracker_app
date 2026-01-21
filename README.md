# HealthTracker App

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)](https://flutter.dev/) [![Firebase](https://img.shields.io/badge/Firebase-Enabled-yellow?logo=firebase)](https://firebase.google.com/) ![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Web-lightgrey)

Health, sleep, heart rate & meditation tracker app with Apple Watch support.

---

## Screenshots

<table>
  <tr>
    <td align="center">
      <a href="screenshots/main_menu.jpg"><img src="screenshots/main_menu.jpg" width="180"/></a><br/>
      Main menu
    </td>
    <td align="center">
      <a href="screenshots/training_menu.jpg"><img src="screenshots/training_menu.jpg" width="180"/></a><br/>
      Training
    </td>
    <td align="center">
      <a href="screenshots/mood_notes.jpg"><img src="screenshots/mood_notes.jpg" width="180"/></a><br/>
      Mood & Notes
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="screenshots/foot_menu.jpg"><img src="screenshots/foot_menu.jpg" width="180"/></a><br/>
      Food
    </td>
    <td align="center">
      <a href="screenshots/foot_detail.jpg"><img src="screenshots/foot_detail.jpg" width="180"/></a><br/>
      Food Detail
    </td>
    <td align="center">
      <a href="screenshots/meditation.jpg"><img src="screenshots/meditation.jpg" width="180"/></a><br/>
      Meditation
    </td>
  </tr>
</table>

---

## Features

- Real-time heart rate measurement via Apple Watch
- Sleep, steps, calories & activity tracking
- Meal reminders and nutrition tips
- Meditation with breathing animation and timer
- Goal setting (e.g., daily steps)
- Goal achievement notifications
- Trusted contact system for emergency situations

---

## Tech Stack

- **Flutter** — cross-platform UI framework
- **Dart** — programming language
- **Firebase** — authentication, Firestore, Storage, notifications
- **HealthKit** — integration with Apple Watch for heart rate, sleep, and activity data
- **`health` package** — wrapper for working with Apple HealthKit
- **Provider** — state management

---

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/25angel/health_tracker_app.git
cd health_tracker_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase:
- Create a project on [Firebase Console](https://console.firebase.google.com)
- Add Android and iOS apps
- Download and place the configuration files:
  - `google-services.json` → `android/app/`
  - `GoogleService-Info.plist` → `ios/Runner/`

Without these files, Firebase won't work (authentication, database, and storage).

4. Run the app:

```bash
flutter run
```

Make sure a device or emulator is connected.

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is protected by copyright. All rights reserved.

---

## Author / Contacts

- Telegram: [@iyunmart](https://t.me/iyunmart)
- GitHub: [25angel](https://github.com/25angel)
