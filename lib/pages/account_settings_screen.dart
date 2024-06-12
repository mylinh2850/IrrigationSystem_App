import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String email;
  final String phone;
  final Function(String, String, String, String) onUpdate;

  AccountSettingsScreen({
    required this.name,
    required this.gender,
    required this.email,
    required this.phone,
    required this.onUpdate,
  });

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cập nhật thông tin'),
        backgroundColor: Colors.green[400],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Họ tên', _nameController, widget.name),
            _buildGenderField(),
            _buildTextField('Email', _emailController, widget.email),
            _buildTextField('Số điện thoại', _phoneController, widget.phone),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(
                  _nameController.text.isEmpty ? widget.name : _nameController.text,
                  _selectedGender,
                  _emailController.text.isEmpty ? widget.email : _emailController.text,
                  _phoneController.text.isEmpty ? widget.phone : _phoneController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Cập nhật'),
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

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Giới tính',
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedGender,
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            },
            items: <String>['Nam', 'Nữ']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
