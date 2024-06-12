import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import '../password_storage.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    bool isAuthenticated = await _authenticate(username, password);
    if (isAuthenticated) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tài khoản hoặc mật khẩu không đúng')),
      );
    }
  }

  Future<bool> _authenticate(String username, String password) async {
    // Simulate a network call for authentication with a short delay
    await Future.delayed(Duration(milliseconds: 50));

    // Use PasswordStorage to check credentials
    if (username == PasswordStorage.username && password == PasswordStorage.password) {
      return true;
    } else {
      return false;
    }
  }

  void _forgotPassword(BuildContext context) {
    // Placeholder for the forgot password feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng quên mật khẩu hiện đang được phát triển')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Đăng nhập'),
        backgroundColor: Colors.green[400],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'images/background.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40.0), // Adjust this value to move elements up or down
                Text(
                  'Nông nghiệp 4.0',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.0),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tài khoản',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _forgotPassword(context),
                    child: Text('Quên mật khẩu?'),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text('Đăng nhập'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full-width button
                    textStyle: TextStyle(fontSize: 18.0),
                    backgroundColor: Colors.green[400], // Button color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
