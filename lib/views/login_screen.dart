import 'package:flutter/material.dart';
import 'package:health_tracker_app/views/health_tracker_screen.dart';
import '/services/auth_service.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), backgroundColor: Color(0xFF5C6BC0)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            _errorMessage != null
                ? Text(_errorMessage!, style: TextStyle(color: Colors.red))
                : Container(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String? email = _emailController.text;
                String? password = _passwordController.text;
                String? result = await _authService.loginWithEmailPassword(
                  email,
                  password,
                );
                if (result != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Failed to login';
                  });
                }
              },
              child: Text('Login with Email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String? result = await _authService.signInWithGoogle();
                if (result != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthTrackerScreen(),
                    ),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Failed to login with Google';
                  });
                }
              },
              child: Text('Login with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
