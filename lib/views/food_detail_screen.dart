import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _addFoodToDiet(
  BuildContext context,
  Map<String, dynamic> food,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance
        .collection('diet_plans')
        .doc(user.uid)
        .collection('foods')
        .add(food);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${food['name']} added to your diet!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class FoodDetailScreen extends StatelessWidget {
  final Map<String, dynamic> food;
  FoodDetailScreen({required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        elevation: 0,
        title: Text(food['name'], style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF5C6BC0),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(food['image_url']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Название и категория
            Text(
              food['name'],
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C6BC0),
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.category, size: 18, color: Colors.grey[600]),
                SizedBox(width: 6),
                Text(
                  food['category'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Карточка с калориями
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.deepPurple),
                  SizedBox(width: 12),
                  Text(
                    '${food['calories']} ккал',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Описание
            Text(
              'Описание',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C6BC0),
              ),
            ),
            SizedBox(height: 10),
            Text(
              food['description'] ?? 'No description available.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 32),

            // Кнопка "Добавить в рацион"
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _addFoodToDiet(context, food);
                },
                icon: Icon(Icons.add),
                label: Text("Добавить"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 252, 252, 255),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
