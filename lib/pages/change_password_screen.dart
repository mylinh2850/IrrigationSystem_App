import 'package:flutter/material.dart';
import '../password_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đổi mật khẩu'),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Mật khẩu hiện tại', _currentPasswordController, obscureText: true),
              _buildTextField('Mật khẩu mới', _newPasswordController, obscureText: true),
              _buildTextField('Xác nhận mật khẩu mới', _confirmPasswordController, obscureText: true),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _changePassword(context);
                  }
                },
                child: Text('Đổi mật khẩu'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full-width button
                  textStyle: TextStyle(fontSize: 18.0),
                  backgroundColor: Colors.green[400], // Button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $label';
          }
          if (label == 'Mật khẩu mới' && value == _currentPasswordController.text) {
            return 'Mật khẩu mới không được giống mật khẩu hiện tại';
          }
          if (label == 'Xác nhận mật khẩu mới' && value != _newPasswordController.text) {
            return 'Mật khẩu xác nhận không khớp';
          }
          return null;
        },
      ),
    );
  }

  void _changePassword(BuildContext context) async {
    bool passwordChanged = await _simulatePasswordChange();

    if (!mounted) return;

    if (passwordChanged) {
      PasswordStorage.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thành công')),
      );
      Navigator.pop(context); // Close the screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thất bại')),
      );
    }
  }

  Future<bool> _simulatePasswordChange() async {
    // Simulate a network call or other async operations
    await Future.delayed(Duration(milliseconds: 50));
    // Return true if password change is successful, false otherwise
    return true;
  }
}
