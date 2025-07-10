import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaloriesScreen extends StatefulWidget {
  @override
  _CaloriesScreenState createState() => _CaloriesScreenState();
}

enum SelectedDay { today, yesterday }

class _CaloriesScreenState extends State<CaloriesScreen> {
  double caloriesBurned = 0.0;
  double weight = 70.0;
  double dailyCalories = 2200.0;
  String goal = 'weight_loss';
  List<FlSpot> caloriesDataPoints = [];
  late Timer _timer;
  SelectedDay selectedDay = SelectedDay.today;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _fetchGoalSettings() async {
    final goalDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('settings')
            .doc('goal')
            .get();

    final data = goalDoc.data();
    if (data != null && data.containsKey('goalType')) {
      setState(() {
        goal = data['goalType'];
      });
    }
  }

  Future<void> _fetchCaloriesData() async {
    setState(() {
      caloriesBurned = 0.0;
      caloriesDataPoints = [];
    });

    final health = Health();

    bool requested = await health.requestAuthorization([
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ]);

    if (requested) {
      DateTime now = DateTime.now();
      DateTime startOfDay, endOfDay;

      if (selectedDay == SelectedDay.today) {
        startOfDay = DateTime(now.year, now.month, now.day);
        endOfDay = startOfDay
            .add(Duration(days: 1))
            .subtract(Duration(seconds: 1));
      } else {
        startOfDay = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: 1));
        endOfDay = startOfDay
            .add(Duration(days: 1))
            .subtract(Duration(seconds: 1));
      }

      List<HealthDataPoint> caloriesData = await health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (caloriesData.isNotEmpty) {
        List<FlSpot> dataPoints = [];
        double totalCalories = 0.0;

        for (int i = 0; i < caloriesData.length; i++) {
          double timeInMinutes =
              (caloriesData[i].dateFrom.hour * 60 +
                      caloriesData[i].dateFrom.minute)
                  .toDouble();
          double calories =
              (caloriesData[i].value as NumericHealthValue).numericValue
                  .toDouble();

          totalCalories += calories;
          dataPoints.add(FlSpot(timeInMinutes, calories));
        }

        setState(() {
          caloriesBurned = totalCalories;
          caloriesDataPoints = dataPoints;
        });
      }
    }
  }

  Future<void> _fetchWeightData() async {
    final health = Health();
    bool requested = await health.requestAuthorization([HealthDataType.WEIGHT]);

    if (requested) {
      List<HealthDataPoint> weightData = await health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: DateTime.now().subtract(Duration(days: 30)),
        endTime: DateTime.now(),
      );

      if (weightData.isNotEmpty) {
        weight =
            (weightData.last.value as NumericHealthValue).numericValue
                .toDouble();
        _calculateDailyCalories(weight);
      }
    }
  }

  void _calculateDailyCalories(double weight) {
    double bmr = calculateBMR(weight, 185, 21, 'male');
    if (goal == 'weight_loss') {
      dailyCalories = bmr * 0.8;
    } else if (goal == 'muscle_gain') {
      dailyCalories = bmr * 1.2;
    } else {
      dailyCalories = bmr;
    }
  }

  double calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  void _startPeriodicUpdates() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchCaloriesData();
    });
  }

  @override
  void initState() {
    super.initState();

    _fetchGoalSettings().then((_) {
      _fetchWeightData().then((_) {
        _fetchCaloriesData();
      });
    });

    _startPeriodicUpdates();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        (dailyCalories > 0)
            ? (caloriesBurned / dailyCalories).clamp(0.0, 1.0)
            : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text('Calories Burned', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('Today'),
                  selected: selectedDay == SelectedDay.today,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedDay = SelectedDay.today;
                        _fetchCaloriesData();
                      });
                    }
                  },
                ),
                SizedBox(width: 12),
                ChoiceChip(
                  label: Text('Yesterday'),
                  selected: selectedDay == SelectedDay.yesterday,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedDay = SelectedDay.yesterday;
                        _fetchCaloriesData();
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Сожженные калории ${selectedDay == SelectedDay.today ? 'Сегодня' : 'Вчера'}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xFF5C6BC0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Text(
                      '${caloriesBurned.toStringAsFixed(1)} kcal',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      color: Colors.greenAccent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Цель: ${dailyCalories.toStringAsFixed(0)} ккал',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Расход калорий за время',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child:
                  caloriesDataPoints.isEmpty
                      ? Center(child: Text('Нет данных'))
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 180,
                                getTitlesWidget: (value, _) {
                                  final hour = (value / 60).floor();
                                  return Text(
                                    '${hour}h',
                                    style: TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 50,
                                getTitlesWidget:
                                    (value, _) => Text('${value.toInt()}'),
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: caloriesDataPoints,
                              isCurved: true,
                              color: Colors.greenAccent[700],
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.greenAccent.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
