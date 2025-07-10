import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String uid = '';
  String email = '';
  String displayName = '';
  String photoUrl = '';
  User? user = FirebaseAuth.instance.currentUser;

  int stepGoal = 3600;
  String goalType = 'weight_loss';
  final TextEditingController _goalController = TextEditingController();

  // Add controllers for new fields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _telegramChatIdController =
      TextEditingController();
  String _gender = 'male'; // default value

  int height = 170; // default height in cm
  int age = 25; // default age

  // Add focus nodes
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _goalFocusNode = FocusNode();
  final FocusNode _telegramChatIdFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _heightFocusNode.dispose();
    _ageFocusNode.dispose();
    _goalFocusNode.dispose();
    _telegramChatIdFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    Map<String, String> userData = await _authService.getUserData();
    setState(() {
      uid = userData['uid'] ?? 'No UID';
      email = userData['email'] ?? 'No Email';
      displayName = userData['displayName'] ?? 'No Name';
      photoUrl = userData['photoUrl'] ?? '';
    });

    final goalDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('settings')
            .doc('goal')
            .get();

    final trustedContactDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('settings')
            .doc('trusted_contact')
            .get();

    final data = goalDoc.data();
    if (goalDoc.exists) {
      setState(() {
        stepGoal = data?['stepGoal'] ?? 3600;
        goalType =
            data != null && data.containsKey('goalType')
                ? data['goalType']
                : 'weight_loss';
        height = data?['height'] ?? 170;
        age = data?['age'] ?? 25;
        _gender = data?['gender'] ?? 'male';

        _goalController.text = stepGoal.toString();
        _heightController.text = height.toString();
        _ageController.text = age.toString();
      });
    } else {
      _goalController.text = stepGoal.toString();
      _heightController.text = height.toString();
      _ageController.text = age.toString();
    }

    if (trustedContactDoc.exists) {
      final contactData = trustedContactDoc.data();
      setState(() {
        _telegramChatIdController.text = contactData?['telegram_chat_id'] ?? '';
      });
    }
  }

  Future<void> _saveGoalSettings() async {
    final stepInput = int.tryParse(_goalController.text);
    final heightInput = int.tryParse(_heightController.text);
    final ageInput = int.tryParse(_ageController.text);

    if (stepInput != null &&
        stepInput > 0 &&
        heightInput != null &&
        heightInput > 0 &&
        ageInput != null &&
        ageInput > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('settings')
          .doc('goal')
          .set({
            'stepGoal': stepInput,
            'goalType': goalType,
            'height': heightInput,
            'age': ageInput,
            'gender': _gender,
          });

      // Save trusted contact info
      if (_telegramChatIdController.text.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('settings')
            .doc('trusted_contact')
            .set({'telegram_chat_id': _telegramChatIdController.text});
      }

      setState(() {
        stepGoal = stepInput;
        height = heightInput;
        age = ageInput;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Settings saved ✅')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Скрываем клавиатуру при нажатии на любое место экрана
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF5C6BC0),
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    user?.photoURL != null && user!.photoURL!.isNotEmpty
                        ? user!.photoURL!
                        : 'https://www.example.com/default-avatar.jpg',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  displayName.isNotEmpty ? displayName : 'No Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  email.isNotEmpty ? email : 'No Email',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                _buildProfileCard('UID', uid),
                _buildProfileCard('Email', email),
                _buildProfileCard('Display Name', displayName),
                SizedBox(height: 24),

                // Step Goal Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              color: Color(0xFF5C6BC0),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Цель по шагам',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _goalController,
                                focusNode: _goalFocusNode,
                                keyboardType: TextInputType.number,
                                onEditingComplete: () {
                                  // Скрываем клавиатуру при нажатии Done/Enter
                                  FocusScope.of(context).unfocus();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Введите цель в шагах',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Height Input
                        Text(
                          'Рост (см):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _heightController,
                          focusNode: _heightFocusNode,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            // Переходим к полю возраста при нажатии Done/Enter
                            FocusScope.of(context).requestFocus(_ageFocusNode);
                          },
                          decoration: InputDecoration(
                            hintText: 'Введите рост в сантиметрах',
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Age Input
                        Text(
                          'Возраст:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _ageController,
                          focusNode: _ageFocusNode,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            // Скрываем клавиатуру при нажатии Done/Enter
                            FocusScope.of(context).unfocus();
                          },
                          decoration: InputDecoration(
                            hintText: 'Введите возраст',
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Gender Selection
                        Text(
                          'Пол:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Мужской'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Женский'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _gender = value ?? 'male';
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        Text(
                          'Доверенный контакт:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _telegramChatIdController,
                          focusNode: _telegramChatIdFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'ID чата в Telegram',
                            hintText: 'Введите ID чата доверенного контакта',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Чтобы получить ID чата, отправьте сообщение боту @get_id_bot в Telegram',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 16),

                        Text(
                          'Цель:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButton<String>(
                          value: goalType,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: 'weight_loss',
                              child: Text('Похудение'),
                            ),
                            DropdownMenuItem(
                              value: 'muscle_gain',
                              child: Text('Набор мышечной массы'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              goalType = value ?? 'weight_loss';
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _saveGoalSettings,
                          icon: Icon(Icons.save),
                          label: Text('Сохранить изменения'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5C6BC0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await _authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5C6BC0),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
