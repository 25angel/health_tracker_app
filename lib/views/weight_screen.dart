import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeightScreen extends StatefulWidget {
  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double weight = 0.0;
  double weightGoal = 85.0;
  List<FlSpot> weightHistory = [];
  List<String> dateLabels = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchWeightData();
    _startPeriodicUpdates();
  }

  void _startPeriodicUpdates() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchWeightData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchWeightData() async {
    final health = Health();
    bool requested = await health.requestAuthorization([HealthDataType.WEIGHT]);

    if (requested) {
      List<HealthDataPoint> weightData = await health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: DateTime.now().subtract(Duration(days: 7)),
        endTime: DateTime.now(),
      );

      if (weightData.isNotEmpty) {
        weightData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        setState(() {
          weight =
              (weightData.last.value as NumericHealthValue).numericValue
                  .toDouble();

          weightHistory =
              weightData.asMap().entries.map((entry) {
                int index = entry.key;
                double w =
                    (entry.value.value as NumericHealthValue).numericValue
                        .toDouble();
                return FlSpot(index.toDouble(), w);
              }).toList();

          dateLabels =
              weightData
                  .map((e) => DateFormat('E').format(e.dateFrom))
                  .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        (weightGoal > 0 && weight > 0)
            ? (weight / weightGoal).clamp(0.0, 1.0)
            : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text('Отслеживание веса', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color(0xFFF8F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Текущий вес',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF5C6BC0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      weight > 0
                          ? '${weight.toStringAsFixed(1)} кг'
                          : 'Нет данных',
                      key: ValueKey<double>(weight),
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Прогресс за неделю',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Container(
                height: 250,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    weightHistory.isEmpty
                        ? Center(child: Text('Нет данных'))
                        : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    int index = value.toInt();
                                    if (index >= 0 &&
                                        index < dateLabels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(dateLabels[index]),
                                      );
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: weightHistory,
                                isCurved: true,
                                color: Colors.indigo,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Прогресс к цели',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: Color(0xFF5C6BC0),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Текущий: ${weight.toStringAsFixed(1)} кг | Цель: ${weightGoal.toStringAsFixed(1)} кг',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _fetchWeightData,
                  icon: Icon(Icons.refresh),
                  label: Text('Обновить данные'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5C6BC0),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
