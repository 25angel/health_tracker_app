import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_tracker_app/views/diet_plan_screen.dart';
import 'package:workmanager/workmanager.dart'; // Импортируем workmanager
import 'views/health_tracker_screen.dart';
import 'views/heart_rate_screen.dart'; // Экран пульса
import 'views/login_screen.dart'; // Экран логина
import 'views/profile_screen.dart'; // Экран профиля
import 'views/calories_screen.dart'; // Экран калорий
import '/views/weight_screen.dart'; // Экран веса
import 'views/sleep_screen.dart';
import 'views/mindfulness_screen.dart';
import 'views/mood_and_notes_screen.dart'; // Экран настроения и заметок
import 'views/steps_screen.dart'; // Экран шагов
import 'views/food_screen.dart'; // Экран питания

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Логика для фоновой задачи
    print("Фоновая задача: $task");

    // Здесь можно вызвать функцию для отправки сообщения и получения геолокации
    // _sendEmergencyMessage();  // Пример вызова задачи
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  Workmanager().initialize(callbackDispatcher); // Инициализация WorkManager
  runApp(HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream:
            FirebaseAuth.instance
                .authStateChanges(), // Следим за состоянием аутентификации
        builder: (context, snapshot) {
          // Если пользователь вошёл, показываем HealthTrackerScreen, иначе LoginScreen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HealthTrackerScreen(); // Если вошёл, показываем HealthTrackerScreen
          } else {
            return LoginScreen(); // Если не вошёл, показываем экран логина
          }
        },
      ),
      routes: {
        '/heart_rate': (context) => HeartRateScreen(),
        '/steps': (context) => StepsScreen(),
        '/mood_and_notes': (context) => MoodAndNotesScreen(),
        '/profile': (context) => ProfileScreen(),
        '/calories': (context) => CaloriesScreen(),
        '/weight': (context) => WeightScreen(), // Экран веса
        '/sleep': (context) => SleepScreen(), // Экран сна
        '/mindfulness': (context) => MindfulnessScreen(), // Экран медитации
        '/food': (context) => FoodScreen(), // Новый экран питания
        "/diet_plan": (context) => DietPlanScreen(),
      },
    );
  }
}
