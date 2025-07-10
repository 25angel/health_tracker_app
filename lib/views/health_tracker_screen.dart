import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/health_service.dart';
import '/services/telegram_service.dart';
import '/services/notification_service.dart';
import 'package:health_tracker_app/widgets/health_card.dart';
import 'package:health_tracker_app/views/discover_screen.dart';
import 'package:health_tracker_app/views/food_screen.dart';
import 'package:health_tracker_app/views/mood_and_notes_screen.dart';
import 'package:health_tracker_app/views/profile_screen.dart';

class HealthTrackerScreen extends StatefulWidget {
  @override
  _HealthTrackerScreenState createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  int _selectedIndex = 0;
  double mindfulnessDuration = 0.0;
  double mindfulnessMinutes = 0.0;

  int steps = 0;
  double heartRate = 0.0;
  double caloriesBurned = 0.0;
  double weight = 0.0;
  double walkingDistance = 0.0;
  String sleepDuration = '0h 0m';

  int stepGoal = 3600;

  User? user = FirebaseAuth.instance.currentUser;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _goalStream;

  @override
  void initState() {
    super.initState();
    _goalStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('settings')
            .doc('goal')
            .snapshots();
    // <--- вот эта строка

    HealthService.init(
      onUpdate: (data) {
        setState(() {
          steps = data['steps'];
          heartRate = data['heartRate'];
          caloriesBurned = data['caloriesBurned'];
          weight = data['weight'];
          walkingDistance = data['walkingDistance'];
          sleepDuration = data['sleepDuration'];
        });

        if (heartRate >= HealthService.upperThreshold ||
            heartRate <= HealthService.lowerThreshold) {
          TelegramService.sendAlertWithLocation(heartRate);
        }
      },
    );

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await NotificationService.init();
  }

  Future<void> _showNotificationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Напоминания о приёме пищи'),
          content: Text(
            'Хотите включить ежедневные напоминания о приёме пищи?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Включить'),
              onPressed: () async {
                await NotificationService.scheduleMealReminders();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Напоминания включены!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _goalStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          final data = snapshot.data!.data();
          if (data != null && data.containsKey('stepGoal')) {
            stepGoal = data['stepGoal'];

            if (data.containsKey('mindfulnessTotalMinutesToday')) {
              mindfulnessMinutes =
                  (data['mindfulnessTotalMinutesToday'] ?? 0).toDouble();
            }
          }
        }

        final List<Widget> _screens = [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF5C6BC0),
              title: Text(
                'Health Tracker',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: _showNotificationDialog,
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          user?.photoURL ??
                              'https://www.example.com/default-avatar.jpg',
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Доброе утро',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            user?.displayName ?? 'Guest',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFD1C4E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Цели на сегодня',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stepGoal > 0 ? steps / stepGoal : 0.0,
                          backgroundColor: Colors.white,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$steps / $stepGoal Шаги',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Данные',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16),
                  HealthCard(
                    title: 'Шаги',
                    value: '$steps шагов',
                    icon: Icons.directions_walk,
                    route: '/steps',
                  ),
                  HealthCard(
                    title: 'Пульс',
                    value: '$heartRate bpm',
                    icon: Icons.favorite,
                    route: '/heart_rate',
                  ),
                  HealthCard(
                    title: 'Сожженные калорий',
                    value: '$caloriesBurned kcal',
                    icon: Icons.local_fire_department,
                    route: '/calories',
                  ),
                  HealthCard(
                    title: 'Сон',
                    value: sleepDuration,
                    icon: Icons.bed,
                    route: '/sleep',
                  ),
                  HealthCard(
                    title: 'Вес',
                    value: '$weight кг',
                    icon: Icons.fitness_center,
                    route: '/weight',
                  ),
                  HealthCard(
                    title: 'Медитация',
                    value: '${mindfulnessMinutes.toStringAsFixed(1)} минут',
                    icon: Icons.self_improvement,
                    route: '/mindfulness',
                  ),
                ],
              ),
            ),
          ),
          DiscoverScreen(),
          MoodAndNotesScreen(),
          FoodScreen(),
          ProfileScreen(),
        ];

        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.grey,
            unselectedItemColor: Colors.black,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Тренировки',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Настроение & Заметки',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.food_bank),
                label: 'Еда',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
          ),
        );
      },
    );
  }
}
