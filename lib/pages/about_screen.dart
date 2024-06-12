import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giới thiệu app'),
        backgroundColor: Colors.green[400],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.3, // Adjust the opacity as needed
            child: Image.asset(
              'images/background.jpg', // Update with the correct path
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tên ứng dụng:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Nông nghiệp 4.0',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Nhà phát triển:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  'LPH_Group',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Phiên bản:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text(
                  '1.0.0',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
