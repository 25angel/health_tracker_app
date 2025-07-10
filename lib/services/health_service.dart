import 'dart:async';
import 'package:health/health.dart';

class HealthService {
  static const double lowerThreshold = 40.0;
  static const double upperThreshold = 180.0;

  static Timer? _timer;

  static void init({required Function(Map<String, dynamic>) onUpdate}) {
    _fetchHealthData(onUpdate); // Первичная загрузка
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      _fetchHealthData(onUpdate);
    });
  }

  static Future<void> _fetchHealthData(
    Function(Map<String, dynamic>) onUpdate,
  ) async {
    final health = Health();

    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.TOTAL_CALORIES_BURNED,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.SLEEP_ASLEEP,
    ];

    bool granted = await health.requestAuthorization(types);
    if (!granted) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay
        .add(Duration(days: 1))
        .subtract(Duration(seconds: 1));

    try {
      final stepsData = await health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      final caloriesData = await health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      final heartRateData = await health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      final weightData = await health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: now.subtract(Duration(days: 30)),
        endTime: now,
      );

      final walkingData = await health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_WALKING_RUNNING],
        startTime: now.subtract(Duration(days: 1)),
        endTime: now,
      );

      final sleepData = await health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: now.subtract(Duration(days: 1)),
        endTime: now,
      );

      int totalSteps = stepsData.fold(
        0,
        (sum, dp) =>
            sum + (dp.value as NumericHealthValue).numericValue.toInt(),
      );
      double totalCalories = caloriesData.fold(
        0.0,
        (sum, dp) =>
            sum + (dp.value as NumericHealthValue).numericValue.toDouble(),
      );
      double lastHeartRate =
          heartRateData.isNotEmpty
              ? (heartRateData
                            ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom)))
                          .first
                          .value
                      is NumericHealthValue
                  ? (heartRateData.first.value as NumericHealthValue)
                      .numericValue
                      .toDouble()
                  : 0.0
              : 0.0;
      double lastWeight =
          weightData.isNotEmpty
              ? (weightData.last.value as NumericHealthValue).numericValue
                  .toDouble()
              : 0.0;
      double lastDistance =
          walkingData.isNotEmpty
              ? (walkingData.last.value as NumericHealthValue).numericValue
                  .toDouble()
              : 0.0;
      String lastSleep =
          sleepData.isNotEmpty
              ? '${sleepData.last.dateFrom.hour}h ${sleepData.last.dateFrom.minute}m'
              : '0h 0m';

      onUpdate({
        'steps': totalSteps,
        'caloriesBurned': double.parse(totalCalories.toStringAsFixed(2)),
        'heartRate': double.parse(lastHeartRate.toStringAsFixed(2)),
        'weight': lastWeight,
        'walkingDistance': lastDistance,
        'sleepDuration': lastSleep,
      });
    } catch (e) {
      print('HealthService error: $e');
    }
  }
}
