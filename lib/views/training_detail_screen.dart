import 'package:flutter/material.dart';

class TrainingCardDetailScreen extends StatefulWidget {
  final Map<String, dynamic> card;

  TrainingCardDetailScreen({required this.card});

  @override
  _TrainingCardDetailScreenState createState() =>
      _TrainingCardDetailScreenState();
}

class _TrainingCardDetailScreenState extends State<TrainingCardDetailScreen> {
  // Список для отслеживания видимости GIF для каждого упражнения
  Map<int, bool> exerciseVisibility = {};

  // Функция для переключения видимости GIF
  void _toggleGifVisibility(int index) {
    setState(() {
      exerciseVisibility[index] = !(exerciseVisibility[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    List exercises =
        widget.card['exercises'] ??
        []; // Получаем упражнения из данных карточки

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text(
          widget.card['title'],
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.card['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Описание
            Text(
              widget.card['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Длительность
            Text(
              'Длительность: ${widget.card['duration']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Категория
            Text(
              'Категория: ${widget.card['category']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Список упражнений
            Text(
              'Упражнения:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  var exercise = exercises[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        exercise['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Follow along with the exercise',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          // Кнопка для переключения видимости GIF
                          ElevatedButton(
                            onPressed: () => _toggleGifVisibility(index),
                            child: Text(
                              exerciseVisibility[index] == true
                                  ? 'Скрыть'
                                  : 'Показать',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Отображаем GIF для каждого упражнения
                          Visibility(
                            visible: exerciseVisibility[index] ?? false,
                            child: Container(
                              height: 150, // Ограничиваем размер GIF
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(exercise['gifUrl']),
                                  fit: BoxFit.contain, // Подгоняем размер GIF
                                ),
                              ),
                            ),
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
