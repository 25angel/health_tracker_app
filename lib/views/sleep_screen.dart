import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SleepScreen extends StatefulWidget {
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  String sleepDuration = '0h 0m';
  DateTime? lastSleepStart;
  int totalSleepMinutes = 0;
  List<BarChartGroupData> weeklySleepBars = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchSleepData();
    _startPeriodicUpdates();
  }

  void _startPeriodicUpdates() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchSleepData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchSleepData() async {
    final health = Health();
    bool requested = await health.requestAuthorization([
      HealthDataType.SLEEP_ASLEEP,
    ]);

    if (requested) {
      try {
        DateTime now = DateTime.now();
        DateTime weekAgo = now.subtract(Duration(days: 6));

        List<HealthDataPoint> sleepData = await health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_ASLEEP],
          startTime: weekAgo,
          endTime: now,
        );

        Map<DateTime, int> sleepPerDay = {};
        for (var point in sleepData) {
          DateTime dateKey = DateTime(
            point.dateFrom.year,
            point.dateFrom.month,
            point.dateFrom.day,
          );
          int duration = point.dateTo.difference(point.dateFrom).inMinutes;
          sleepPerDay.update(
            dateKey,
            (val) => val + duration,
            ifAbsent: () => duration,
          );
        }

        List<DateTime> last7Days = List.generate(7, (index) {
          return DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: 6 - index));
        });

        weeklySleepBars =
            last7Days.asMap().entries.map((entry) {
              final i = entry.key;
              final date = entry.value;
              double hours = (sleepPerDay[date] ?? 0) / 60.0;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: hours,
                    color: Color(0xFF5C6BC0),
                    width: 14,
                  ),
                ],
              );
            }).toList();

        if (sleepData.isNotEmpty) {
          final latest = sleepData.last;
          final duration = latest.dateTo.difference(latest.dateFrom);
          setState(() {
            lastSleepStart = latest.dateFrom;
            totalSleepMinutes = duration.inMinutes;
            sleepDuration =
                '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
          });
        }
      } catch (e) {
        print("Ошибка при получении данных: $e");
      }
    }
  }

  String _getDayLabel(int index, List<DateTime> days) {
    final date = days[index];
    return DateFormat('E').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalSleepMinutes / 480; // 8 часов = 480 минут
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text('Мониторинг сна', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color(0xFFF9F7FC),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🛏️ Сводка о сне',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Последнее время сна:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.nights_stay, color: Color(0xFF5C6BC0)),
                        SizedBox(width: 8),
                        Text(
                          sleepDuration,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C6BC0),
                          ),
                        ),
                      ],
                    ),
                    if (lastSleepStart != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Последнее время сна: ${DateFormat('yyyy-MM-dd HH:mm').format(lastSleepStart!)}',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Прогресс к идеальному сну (8ч):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: Color(0xFF5C6BC0),
                minHeight: 10,
              ),
              SizedBox(height: 8),
              Text(
                "Вы на пути к полной ночи сна.",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 32),
              Text(
                'Сон за эту неделю',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.7,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 24,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          DateTime date = DateTime.now().subtract(
                            Duration(days: 6 - group.x.toInt()),
                          );
                          String dayStr = DateFormat('MMM d').format(date);
                          return BarTooltipItem(
                            '$dayStr\n${rod.toY.toStringAsFixed(1)}h',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            DateTime date = DateTime.now().subtract(
                              Duration(days: 6 - value.toInt()),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(DateFormat('E').format(date)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 4),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: weeklySleepBars,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _fetchSleepData,
                  icon: Icon(Icons.refresh),
                  label: Text(
                    'Обновить данные',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5C6BC0),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
