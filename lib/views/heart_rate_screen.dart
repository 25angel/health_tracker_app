import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';

class HeartRateScreen extends StatefulWidget {
  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  double heartRate = 0.0;
  String lastMeasurementTime = '00:00';
  String heartRateRange = '0—0 bpm';
  List<FlSpot> heartRateDataPoints = [];

  final double _lowerThreshold = 40.0;
  final double _upperThreshold = 180.0;

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData(); // Запрашиваем данные при старте
  }

  // Функция для получения данных о пульсе
  Future<void> _fetchHeartRateData() async {
    final health = Health();

    bool requested = await health.requestAuthorization([
      HealthDataType.HEART_RATE,
    ]);

    if (requested) {
      DateTime startOfDay = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      DateTime endOfDay = startOfDay
          .add(Duration(days: 1))
          .subtract(Duration(seconds: 1));

      List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (heartRateData.isNotEmpty) {
        heartRateData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

        List<FlSpot> dataPoints = [];
        for (var data in heartRateData) {
          double timeInMinutes =
              (data.dateFrom.hour * 60 + data.dateFrom.minute).toDouble();
          double rate =
              (data.value as NumericHealthValue).numericValue.toDouble();
          dataPoints.add(FlSpot(timeInMinutes, rate));
        }

        var latestData = heartRateData.first;
        double rate =
            (latestData.value as NumericHealthValue).numericValue.toDouble();

        setState(() {
          heartRate = rate;
          lastMeasurementTime = latestData.dateFrom
              .toLocal()
              .toString()
              .substring(11, 16); // Последнее измерение
          heartRateDataPoints = dataPoints;
          heartRateRange = '$rate bpm';
        });
      }
    }
  }

  // Рекомендации по улучшению пульса
  String getHeartRateRecommendation() {
    if (heartRate < _lowerThreshold) {
      return "Ваш пульс слишком низкий. Пожалуйста, отдохните и проконсультируйтесь с врачом.";
    } else if (heartRate > _upperThreshold) {
      return "Ваш пульс слишком высокий. Попробуйте расслабиться и сделать глубокие вдохи.";
    } else {
      return "Ваш пульс в норме. Продолжайте поддерживать активность и здоровый образ жизни.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text('Пульс', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок экрана
              Text(
                'Мониторинг пульса',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Текущее значение пульса
              Text(
                'Нынешний пульс: $heartRate bpm',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),

              // Рекомендации
              Text(
                getHeartRateRecommendation(),
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              SizedBox(height: 16),

              // График пульса
              Container(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: heartRateDataPoints,
                        isCurved: true,
                        color: Colors.blue,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Последний замер
              Text(
                'Последний замер: $lastMeasurementTime',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
