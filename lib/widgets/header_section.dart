import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Thành phố Hồ Chí Minh',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0),
              Text(
                '32.5 C',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                formattedDate,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Xin chào',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.person,
                size: 50.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
