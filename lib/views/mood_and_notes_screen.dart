import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'mindfulness_screen.dart'; // <--- Импортируем экран медитации

class MoodAndNotesScreen extends StatefulWidget {
  @override
  _MoodAndNotesScreenState createState() => _MoodAndNotesScreenState();
}

class _MoodAndNotesScreenState extends State<MoodAndNotesScreen> {
  TextEditingController _noteController = TextEditingController();
  String _selectedMood = 'Радость';

  final List<String> moods = [
    'Радость',
    'Грусть',
    'Возбуждение',
    'Усталось',
    'Стресс',
    'Нейтральный',
  ];

  List<Map<String, dynamic>> moodNotes = [];
  Map<String, int> moodFrequency = {};

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addMoodAndNote() async {
    if (_noteController.text.isNotEmpty) {
      final entry = {
        'user_id': user?.uid,
        'mood': _selectedMood,
        'note': _noteController.text,
        'timestamp': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('mood_notes').add(entry);

      setState(() {
        moodNotes.insert(0, entry);
        _updateMoodFrequency(entry['mood'] as String);
        _noteController.clear();
        _selectedMood = 'Радость';
      });

      // <<< ДОБАВЛЯЕМ: если Грусть или Стресс, предложить перейти к медитации
      if (entry['mood'] == 'Грусть' || entry['mood'] == 'Стресс') {
        _showMindfulnessSuggestion();
      }
      // >>>
    }
  }

  Future<void> _loadMoodNotes() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('mood_notes')
            .where('user_id', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      moodNotes = snapshot.docs.map((doc) => doc.data()).toList();
      _calculateMoodFrequency();
    });
  }

  void _calculateMoodFrequency() {
    moodFrequency.clear();
    for (var note in moodNotes) {
      final mood = note['mood'];
      moodFrequency[mood] = (moodFrequency[mood] ?? 0) + 1;
    }
  }

  void _updateMoodFrequency(String mood) {
    moodFrequency[mood] = (moodFrequency[mood] ?? 0) + 1;
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'Радость':
        return '😊';
      case 'Грусть':
        return '😢';
      case 'Возбуждение':
        return '😃';
      case 'Усталось':
        return '😴';
      case 'Стресс':
        return '😰';
      case 'Нейтральный':
      default:
        return '😐';
    }
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'Радость':
        return Colors.yellow.shade700;
      case 'Грусть':
        return Colors.blueGrey;
      case 'Возбуждение':
        return Colors.orange;
      case 'Усталось':
        return Colors.brown;
      case 'Стресс':
        return Colors.red;
      case 'Нейтральный':
      default:
        return Colors.grey;
    }
  }

  // <<< ДОБАВИЛ: функция показа диалога
  void _showMindfulnessSuggestion() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Расслабьтесь 🧘‍♂️'),
            content: Text(
              'Вы выбрали грусть или стресс. Хотите сделать короткую медитацию, чтобы почувствовать себя лучше?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Нет'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MindfulnessScreen()),
                  );
                },
                child: Text('Да'),
              ),
            ],
          ),
    );
  }
  // >>>

  @override
  void initState() {
    super.initState();
    _loadMoodNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text(
          'Настроение & Заметки',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(
            context,
          ).unfocus(); // Скрываем клавиатуру при тапе по экрану
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Отслеживай свое настроение & мысли',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      'Настроение: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _moodColor(_selectedMood),
                          width: 2,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedMood,
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: _moodColor(_selectedMood),
                        ),
                        underline: SizedBox(),
                        borderRadius: BorderRadius.circular(15),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (String? newMood) {
                          setState(() {
                            _selectedMood = newMood!;
                          });
                        },
                        items:
                            moods.map((String mood) {
                              return DropdownMenuItem<String>(
                                value: mood,
                                child: Text(
                                  mood,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _moodColor(mood),
                                    fontWeight:
                                        _selectedMood == mood
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Напиши свои мысли или заметки здесь...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _addMoodAndNote,
                  child: Text('Добавить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5C6BC0),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    textStyle: TextStyle(fontSize: 18),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                if (moodFrequency.isNotEmpty) ...[
                  Text(
                    'График настроения',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value == value.toInt()) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final mood =
                                    moods[value.toInt() % moods.length];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    mood,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1,
                          verticalInterval: 1,
                          checkToShowHorizontalLine: (value) => true,
                          checkToShowVerticalLine: (value) => true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.3),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.3),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        barGroups: List.generate(moods.length, (i) {
                          final mood = moods[i];
                          final count = moodFrequency[mood] ?? 0;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: _moodColor(mood),
                                width: 16,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: moodNotes.length,
                  itemBuilder: (context, index) {
                    final entry = moodNotes[index];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final snapshot =
                            await FirebaseFirestore.instance
                                .collection('mood_notes')
                                .where('user_id', isEqualTo: user?.uid)
                                .where('mood', isEqualTo: entry['mood'])
                                .where('note', isEqualTo: entry['note'])
                                .get();
                        if (snapshot.docs.isNotEmpty) {
                          await snapshot.docs.first.reference.delete();
                          setState(() {
                            moodNotes.removeAt(index);
                            _calculateMoodFrequency();
                          });
                        }
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Color(0xFF5C6BC0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            'Настроение: ${entry['mood']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _moodColor(entry['mood']),
                            ),
                          ),
                          subtitle: Text(
                            'Заметка: ${entry['note']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF607D8B),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
