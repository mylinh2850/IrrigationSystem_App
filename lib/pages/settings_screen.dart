import 'package:flutter/material.dart';
import '../pages/login_screen.dart'; // Update to the new file name
import '../pages/about_screen.dart'; // Import the about screen
import '../pages/change_password_screen.dart'; // Import the change password screen
import '../pages/view_user_info_screen.dart'; // Import the view user info screen

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: Center(
          child: Text('Cài Đặt'),
        ),
        backgroundColor: Colors.green[400],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsOption(
              context,
              icon: Icons.info,
              title: 'Giới thiệu app',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen()),
                );
              },
            ),
            SizedBox(height: 16.0),
            _buildSettingsOption(
              context,
              icon: Icons.account_circle,
              title: 'Thông tin tài khoản',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewUserInfoScreen()),
                );
              },
            ),
            SizedBox(height: 16.0),
            _buildSettingsOption(
              context,
              icon: Icons.lock,
              title: 'Đổi mật khẩu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            SizedBox(height: 16.0),
            _buildSettingsOption(
              context,
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 30.0),
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    );
  }
}
