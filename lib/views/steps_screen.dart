import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class StepsScreen extends StatefulWidget {
  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final health = Health();
  int steps = 0;
  double distance = 0.0;
  final int goalSteps = 3600;
  List<int> weeklySteps = [0, 0, 0, 0, 0, 0, 0];
  String quote = '';
  List<String> quotes = [
    "Каждый шаг — шаг к лучшему себе!",
    "Ходить — бесплатно, эффективно и без побочек.",
    "Шаги считаются даже до холодильника 😉",
    "Сегодня ты на шаг ближе к победе!",
    "Продолжай двигаться — ты молодец!",
  ];

  List<String> achievements = [];

  @override
  void initState() {
    super.initState();
    _fetchSteps();
    quote = quotes[Random().nextInt(quotes.length)];
  }

  Future<void> _fetchSteps() async {
    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay
          .add(Duration(days: 1))
          .subtract(Duration(seconds: 1));

      List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      int totalSteps = 0;
      for (var point in stepsData) {
        totalSteps += (point.value as NumericHealthValue).numericValue.toInt();
      }

      for (int i = 0; i < 7; i++) {
        DateTime start = now.subtract(Duration(days: i));
        DateTime s = DateTime(start.year, start.month, start.day);
        DateTime e = s.add(Duration(days: 1)).subtract(Duration(seconds: 1));

        List<HealthDataPoint> daily = await health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: s,
          endTime: e,
        );

        int daySteps = 0;
        for (var p in daily) {
          daySteps += (p.value as NumericHealthValue).numericValue.toInt();
        }
        weeklySteps[6 - i] = daySteps;
      }

      setState(() {
        steps = totalSteps;
        distance = steps * 0.00076;
        _checkAchievements();
      });
    }
  }

  void _checkAchievements() {
    achievements.clear();
    if (steps >= 1000) achievements.add("🥉 1000 шагов — Новичок");
    if (steps >= 5000) achievements.add("🥈 5000 шагов — Продвинутый");
    if (steps >= 10000) achievements.add("🥇 10000 шагов — Мастер ходьбы");
  }

  @override
  Widget build(BuildContext context) {
    double progress = (steps / goalSteps).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text('Шаги', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Шаги за сегодня',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 220, 219, 220),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$steps',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('пройденные шаги за сегодня'),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% от твоей цели ($goalSteps шагов)',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Пройдено: ${distance.toStringAsFixed(2)} км',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Шаги за последние 7 дней',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(
                      7,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: weeklySteps[i].toDouble(),
                            width: 12,
                            color: Colors.cyan,
                          ),
                        ],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      topTitles: AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              'Пн',
                              'Вт',
                              'Ср',
                              'Чт',
                              'Пт',
                              'Суб',
                              'Воскр',
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(days[value.toInt() % 7]),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (achievements.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Достижения',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...achievements.map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          a,
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  quote,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _fetchSteps,
                  icon: Icon(Icons.refresh),
                  label: Text('Обновить данные'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 220, 219, 220),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
