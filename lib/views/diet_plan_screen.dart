import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';

class DietPlanScreen extends StatefulWidget {
  @override
  _DietPlanScreenState createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> selectedFoods = [];
  Map<String, String> documentIds = {};
  double totalCalories = 0.0;
  double dailyCalories = 2000;

  @override
  void initState() {
    super.initState();
    _fetchGoalAndCalories();
    _fetchDietPlan();
  }

  Future<void> _fetchGoalAndCalories() async {
    final user = FirebaseAuth.instance.currentUser;
    final health = Health();
    String goal = 'weight_loss';
    double weight = 70.0;
    double height = 170.0;
    int age = 25;
    String gender = 'male';

    if (user != null) {
      final goalDoc =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('settings')
              .doc('goal')
              .get();
      final data = goalDoc.data();
      if (data != null) {
        goal = data['goalType'] ?? 'weight_loss';
        height = (data['height'] ?? 170).toDouble();
        age = data['age'] ?? 25;
        gender = data['gender'] ?? 'male';
      }
    }

    bool requested = await health.requestAuthorization([HealthDataType.WEIGHT]);
    if (requested) {
      final weightData = await health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: DateTime.now().subtract(Duration(days: 30)),
        endTime: DateTime.now(),
      );

      if (weightData.isNotEmpty) {
        weight =
            (weightData.last.value as NumericHealthValue).numericValue
                .toDouble();
      }
    }

    double bmr = _calculateBMR(weight, height, age, gender);
    double calculatedCalories =
        goal == 'weight_loss'
            ? bmr * 0.8
            : goal == 'muscle_gain'
            ? bmr * 1.2
            : bmr;

    setState(() {
      dailyCalories = calculatedCalories;
    });
  }

  double _calculateBMR(double weight, double height, int age, String gender) {
    return gender == 'male'
        ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
  }

  Future<void> _fetchDietPlan() async {
    final userDoc = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await _firestore
            .collection('diet_plans')
            .doc(userDoc)
            .collection('foods')
            .get();

    List<Map<String, dynamic>> foods = [];
    Map<String, String> ids = {};
    double total = 0.0;

    for (var doc in snapshot.docs) {
      var data = doc.data();
      foods.add({...data, 'docId': doc.id});
      ids[data['name']] = doc.id;
      if (data['eaten'] == true) {
        total += double.tryParse(data['calories'].toString()) ?? 0.0;
      }
    }

    setState(() {
      selectedFoods = foods;
      documentIds = ids;
      totalCalories = total;
    });
  }

  Future<void> _toggleEatenStatus(Map<String, dynamic> food) async {
    final userDoc = FirebaseAuth.instance.currentUser!.uid;
    final docId = food['docId'];
    final newStatus = !(food['eaten'] == true);
    await _firestore
        .collection('diet_plans')
        .doc(userDoc)
        .collection('foods')
        .doc(docId)
        .update({'eaten': newStatus});
    _fetchDietPlan();
  }

  Future<void> _removeFoodFromDiet(String foodName) async {
    final userDoc = FirebaseAuth.instance.currentUser!.uid;
    String? docId = documentIds[foodName];
    if (docId != null) {
      await _firestore
          .collection('diet_plans')
          .doc(userDoc)
          .collection('foods')
          .doc(docId)
          .delete();
      _fetchDietPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        (dailyCalories > 0)
            ? (totalCalories / dailyCalories).clamp(0.0, 1.0)
            : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Мое питания дня"),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Съедено: ${totalCalories.toStringAsFixed(0)} / ${dailyCalories.toStringAsFixed(0)} ккал",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFoods.length,
                itemBuilder: (context, index) {
                  var food = selectedFoods[index];
                  final isEaten = food['eaten'] == true;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isEaten
                              ? Colors.green.shade50
                              : Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              food['image_url'],
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration:
                                        isEaten
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${food['calories']} ккал',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isEaten
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isEaten ? Colors.green : Colors.deepPurple,
                            ),
                            onPressed: () => _toggleEatenStatus(food),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _removeFoodFromDiet(food['name']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
