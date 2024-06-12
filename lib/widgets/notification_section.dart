import 'package:flutter/material.dart';

class NotificationSection extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Color backgroundColor;
  final VoidCallback onClearNotifications;

  NotificationSection({
    required this.notifications,
    required this.backgroundColor,
    required this.onClearNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
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
          Center( // Căn giữa tiêu đề
            child: Text(
              'Bảng tin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          if (notifications.isEmpty)
            Center( // Căn giữa thông báo không có thông báo
              child: Text(
                'Không có thông báo',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          else
            for (var notification in notifications)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      notification['isError'] ? Icons.error : Icons.notifications,
                      color: notification['isError'] ? Colors.red : Colors.blue,
                    ),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        '${notification['time']} | ${notification['message']}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
          SizedBox(height: 16.0),
          Center(
            child: ElevatedButton.icon(
              onPressed: onClearNotifications,
              icon: Icon(Icons.clear_all),
              label: Text('Xóa bảng tin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
