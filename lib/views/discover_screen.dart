import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'training_detail_screen.dart'; // Импортируем экран деталей

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String selectedCategory = 'Все'; // Начальная категория

  // Список категорий для фильтрации
  final List<String> categories = ['Все', 'Похудение', 'Набор мышечной массы'];

  // Список карточек с данными (например, с Firebase)
  Future<List<Map<String, dynamic>>> fetchTrainingCards() async {
    QuerySnapshot snapshot;
    if (selectedCategory == 'Все') {
      snapshot =
          await FirebaseFirestore.instance.collection('trainingcards').get();
    } else {
      snapshot =
          await FirebaseFirestore.instance
              .collection('trainingcards')
              .where('category', isEqualTo: selectedCategory)
              .get();
    }

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: SingleChildScrollView(
        // Оборачиваем содержимое в ScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Фильтры по категориям
              SingleChildScrollView(
                // Добавляем горизонтальную прокрутку для фильтров
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (isSelected) {
                              setState(() {
                                selectedCategory =
                                    isSelected ? category : 'Все';
                              });
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 16),

              // Отображение карточек
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchTrainingCards(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No activities found.'));
                  }

                  var trainingCards = snapshot.data!;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: trainingCards.length,
                    itemBuilder: (context, index) {
                      var card = trainingCards[index];
                      return GestureDetector(
                        onTap: () {
                          // Переход к экрану с деталями тренировки
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TrainingCardDetailScreen(
                                    card:
                                        card, // Передаем данные карточки на экран
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Ограничиваем размер изображения, чтобы не было переполнения
                              Container(
                                height: 85, // Ограничение по высоте
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(card['imageUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Заголовок с ограничением
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  card['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3, // Ограничиваем количество строк
                                  overflow:
                                      TextOverflow.ellipsis, // Обрезаем текст
                                ),
                              ),
                              SizedBox(height: 8),
                              // Подзаголовки
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Длительность: ${card['duration']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1, // Ограничиваем количество строк
                                  overflow:
                                      TextOverflow.ellipsis, // Обрезаем текст
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Категория: ${card['category']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1, // Ограничиваем количество строк
                                  overflow:
                                      TextOverflow.ellipsis, // Обрезаем текст
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
