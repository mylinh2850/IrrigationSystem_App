import 'package:flutter/material.dart';
import 'account_settings_screen.dart'; // Import the account settings screen

class ViewUserInfoScreen extends StatefulWidget {
  @override
  _ViewUserInfoScreenState createState() => _ViewUserInfoScreenState();
}

class _ViewUserInfoScreenState extends State<ViewUserInfoScreen> {
  String _name = "Nguyen Van A";
  String _gender = "Nam";
  String _email = "nguyenvana@example.com";
  String _phone = "0123456789";

  void _updateUserInfo(String name, String gender, String email, String phone) {
    setState(() {
      _name = name;
      _gender = gender;
      _email = email;
      _phone = phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin tài khoản'),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoRow('Họ tên:', _name),
                  _buildUserInfoRow('Giới tính:', _gender),
                  _buildUserInfoRow('Email:', _email),
                  _buildUserInfoRow('Số điện thoại:', _phone),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountSettingsScreen(
                      name: _name,
                      gender: _gender,
                      email: _email,
                      phone: _phone,
                      onUpdate: _updateUserInfo,
                    ),
                  ),
                );
              },
              child: Text('Cập nhật thông tin'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
                textStyle: TextStyle(fontSize: 18.0),
                backgroundColor: Colors.green[400], // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}
