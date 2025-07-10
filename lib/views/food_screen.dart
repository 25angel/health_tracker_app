import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food_detail_screen.dart';

class FoodScreen extends StatefulWidget {
  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  double weight = 0.0;
  String goal = 'weight_loss';
  String mealType = '';
  double dailyCalories = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchGoal().then((_) => _fetchWeightData());
    _determineMealType();
  }

  Future<void> _fetchGoal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final goalDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('settings')
              .doc('goal')
              .get();

      final data = goalDoc.data();
      if (data != null) {
        setState(() {
          goal = data['goalType'] ?? 'weight_loss';
          // Get user's physical parameters
          double height = (data['height'] ?? 170).toDouble();
          int age = data['age'] ?? 25;
          String gender = data['gender'] ?? 'male';

          if (weight > 0) {
            _calculateDailyCalories(weight, height, age, gender);
          }
        });
      }
    }
  }

  void _determineMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 8 && hour < 11) {
      mealType = 'Завтрак';
    } else if (hour >= 13 && hour < 15) {
      mealType = 'Обед';
    } else if (hour >= 19 && hour < 21) {
      mealType = 'Ужин';
    } else {
      mealType = 'Перекус';
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

        // Fetch goal settings after getting weight
        await _fetchGoal();
      }
    }
  }

  void _calculateDailyCalories(
    double weight,
    double height,
    int age,
    String gender,
  ) {
    double bmr = calculateBMR(weight, height, age, gender);
    if (goal == 'weight_loss') {
      dailyCalories = bmr * 0.8;
    } else if (goal == 'muscle_gain') {
      dailyCalories = bmr * 1.2;
    } else {
      dailyCalories = bmr;
    }
  }

  double calculateBMR(double weight, double height, int age, String gender) {
    return gender == 'male'
        ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
  }

  Future<List<Map<String, dynamic>>> _getFoodRecommendations() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('foods')
            .where('goal', isEqualTo: goal)
            .where('meal_time', isEqualTo: mealType)
            .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _addFoodToDiet(Map<String, dynamic> food) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('diet_plans')
          .doc(user.uid)
          .collection('foods')
          .add(food);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${food['name']} добавлен в ваш план питания на день!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData goalIcon =
        goal == 'weight_loss'
            ? Icons.spa
            : goal == 'muscle_gain'
            ? Icons.fitness_center
            : Icons.balance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Рекомендации по еде'),
            IconButton(
              icon: Icon(Icons.list_alt_rounded),
              onPressed: () => Navigator.pushNamed(context, '/diet_plan'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFoodRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recommendations available.'));
          }

          List<Map<String, dynamic>> foods = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  color: Colors.deepPurple.shade50,
                  child: ListTile(
                    leading: Icon(goalIcon, color: Colors.deepPurple, size: 36),
                    title: Text('Тип питания: $mealType'),
                    subtitle: Text(
                      'Калорий за день: ${dailyCalories.toStringAsFixed(0)} ккал',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: foods.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var food = foods[index];
                      return Material(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        child: InkWell(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FoodDetailScreen(food: food),
                                ),
                              ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    food['image_url'],
                                    height: 64,
                                    width: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('Калорий: ${food['calories']} ккал'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF5C6BC0),
                                  ),
                                  onPressed: () => _addFoodToDiet(food),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
