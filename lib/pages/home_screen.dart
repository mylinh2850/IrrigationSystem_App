import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../widgets/header_section.dart';
import '../widgets/project_section.dart';
import '../widgets/notification_section.dart';
import 'login_screen.dart';
import '../watering_schedule_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WateringScheduleProvider? _scheduleProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduleProvider == null) {
      _scheduleProvider = Provider.of<WateringScheduleProvider>(context);
      // _scheduleProvider!.connect(); // Loại bỏ dòng này để tránh kết nối lại
    }
    // Ensure local time zone is initialized
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

  @override
  void dispose() {
    // Loại bỏ ngắt kết nối để duy trì kết nối giữa các trang
    // _scheduleProvider?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('App Quản lý nông nghiệp'),
        ),
        backgroundColor: Colors.green[400],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            HeaderSection(),
            SizedBox(height: 16.0),
            Consumer<WateringScheduleProvider>(
              builder: (context, scheduleProvider, child) {
                return ProjectSection(
                  temperature: scheduleProvider.temperature,
                  moisture: scheduleProvider.humidity,
                );
              },
            ),
            SizedBox(height: 16.0),
            Consumer<WateringScheduleProvider>(
              builder: (context, scheduleProvider, child) {
                var notifications = scheduleProvider.completedSchedules.map((schedule) {
                  String completedTime = schedule['completedTime'] != null 
                    ? DateFormat('HH:mm').format(tz.TZDateTime.from(DateTime.parse(schedule['completedTime']), tz.local))
                    : 'Unknown time';
                  return {
                    'time': completedTime,
                    'message': 'Lịch tưới ${schedule['name']} vừa được hoàn thành!',
                    'isError': false,
                  };
                }).toList();

                return NotificationSection(
                  notifications: notifications,
                  backgroundColor: Colors.white,
                  onClearNotifications: () {
                    context.read<WateringScheduleProvider>().resetSchedule();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
