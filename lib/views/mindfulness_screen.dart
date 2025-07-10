import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MindfulnessScreen extends StatefulWidget {
  @override
  _MindfulnessScreenState createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen>
    with TickerProviderStateMixin {
  String mindfulnessStatus = 'Медитация';
  double mindfulnessDuration = 0.0;
  String quote = '';
  int selectedMinutes = 1;
  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  bool _isMeditating = false;
  late AnimationController _breatheController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<QuerySnapshot>? _mindfulnessSubscription;

  final List<String> quotes = [
    'Мир начинается с глубокого вдоха.',
    'Отпустите. Дышите. Просто будь.',
    'Настоящий момент - это все, что у вас есть.',
    'Ваш спокойный разум - главное оружие против стресса.',
    'Осознанность - ключ к счастью.',
  ];

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);

    _selectRandomQuote();
    _subscribeToMindfulnessSessions();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _sessionTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _mindfulnessSubscription?.cancel();
    super.dispose();
  }

  void _selectRandomQuote() {
    final rnd = Random();
    setState(() {
      quote = quotes[rnd.nextInt(quotes.length)];
    });
  }

  void _subscribeToMindfulnessSessions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayMidnight = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _mindfulnessSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mindfulness_sessions')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayMidnight),
        )
        .snapshots()
        .listen((snapshot) {
          double totalMinutes = 0.0;
          for (var doc in snapshot.docs) {
            totalMinutes += (doc.data()['duration_minutes'] ?? 0).toDouble();
          }
          setState(() {
            mindfulnessDuration = totalMinutes;
          });
        });
  }

  void _startMeditation() {
    _remainingSeconds = selectedMinutes * 60;
    _isMeditating = true;
    _playOceanSound();

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        _isMeditating = false;
        _saveMindfulnessSession();
        _audioPlayer.stop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Медитация завершена ✨')));

        setState(() {});
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  Future<void> _saveMindfulnessSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mindfulness_sessions');

    await sessionRef.add({
      'duration_minutes': selectedMinutes,
      'timestamp': Timestamp.now(),
    });

    // Теперь обновляем общее количество минут за сегодня
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final totalSnapshot =
        await sessionRef
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
            )
            .get();

    double totalMinutes = 0.0;
    for (var doc in totalSnapshot.docs) {
      totalMinutes += (doc.data()['duration_minutes'] ?? 0).toDouble();
    }

    // Обновляем поле в settings
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('goal') // или другой doc, если нужно
        .set({
          'mindfulnessTotalMinutesToday': totalMinutes,
        }, SetOptions(merge: true));
  }

  void _playOceanSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/ocean.mp3'));
  }

  String formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double progress = mindfulnessDuration / 30.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '🧘 Медитация и баланс',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 96, 157, 255),
              Color.fromARGB(255, 187, 241, 247),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _breatheController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        254,
                        255,
                        252,
                      ).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.self_improvement,
                          size: 60,
                          color: const Color.fromARGB(255, 5, 5, 5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          mindfulnessStatus,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Сегодня: ${mindfulnessDuration.toStringAsFixed(1)} мин',
                          style: TextStyle(
                            color: const Color.fromARGB(179, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          "Прогресс дня",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          color: Color(0xFF5C6BC0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${mindfulnessDuration.toStringAsFixed(1)} / 30 мин',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFEEE5FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Color(0xFF5C6BC0),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          quote,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                if (!_isMeditating) ...[
                  DropdownButton<int>(
                    value: selectedMinutes,
                    dropdownColor: Colors.white,
                    onChanged:
                        (value) => setState(() => selectedMinutes = value!),
                    items:
                        [1, 10, 15]
                            .map(
                              (min) => DropdownMenuItem<int>(
                                value: min,
                                child: Text('$min минут'),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _startMeditation,
                    icon: Icon(Icons.play_arrow),
                    label: Text('Начать медитацию'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF5C6BC0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: StadiumBorder(),
                    ),
                  ),
                ] else ...[
                  Text(
                    formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _sessionTimer?.cancel();
                      _audioPlayer.stop();
                      setState(() => _isMeditating = false);
                    },
                    child: Text('Остановить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      shape: StadiumBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
