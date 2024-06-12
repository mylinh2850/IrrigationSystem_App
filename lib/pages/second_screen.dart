import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../widgets/header_section.dart';
import '../watering_schedule_provider.dart';
import '../widgets/wave_progress_indicator.dart';
import 'login_screen.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: Center(child: Text('Tưới Nước')),
        backgroundColor: Colors.green[400],
      ),
      body: Consumer<WateringScheduleProvider>(
        builder: (context, scheduleProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                HeaderSection(),
                SizedBox(height: 16.0),
                if (scheduleProvider.hasCurrentSchedule)
                  _buildScheduleCard(
                      scheduleProvider.currentSchedule, 'Lịch tưới hiện tại',
                      isCurrent: true),
                SizedBox(height: 16.0),
                if (scheduleProvider.waitingSchedules.isNotEmpty)
                  _buildPendingSchedules(scheduleProvider.waitingSchedules),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/new').then((value) {
                      if (value == true) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tạo lịch tưới thành công')),
                          );
                        }
                      }
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Tạo mới lịch tưới nước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5.0,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCompletedSchedules(
                        context, scheduleProvider.completedSchedules);
                  },
                  icon: Icon(Icons.history),
                  label: Text('Lịch sử tưới nước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule, String title,
      {bool isCurrent = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                WaveProgressIndicator(
                  value: schedule['progress'] / 100,
                  size: 60,
                  borderWidth: 5.0,
                  color: Colors.blue[100]!,
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tên lịch tưới: ${schedule['name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Khu vực tưới: ${schedule['area']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          schedule['timeLeft'] == 'đang chờ'
                              ? 'Trạng thái: ${schedule['timeLeft']}'
                              : (schedule['timeLeft'] == 'đang tính toán'
                                  ? 'Thời gian dự kiến: ${schedule['timeLeft']}'
                                  : 'Thời gian còn lại: ${double.tryParse(schedule['timeLeft'].toString())?.toStringAsFixed(1) ?? schedule['timeLeft']} giây'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSchedules(List<Map<String, dynamic>> pendingSchedules) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
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
          Text(
            'Lịch tưới đang chờ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: pendingSchedules.map((schedule) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    WaveProgressIndicator(
                      value: schedule['progress'] / 100,
                      size: 60,
                      borderWidth: 5.0,
                      color: Colors.blue[100]!,
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tên lịch tưới: ${schedule['name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Khu vực tưới: ${schedule['area']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (schedule['startTime'] != null)
                              Text(
                                'Thời gian dự kiến: ${_formatTime(schedule['startTime'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              schedule['timeLeft'] == 'đang chờ'
                                  ? 'Trạng thái: ${schedule['timeLeft']}'
                                  : (schedule['timeLeft'] == 'đang tính toán'
                                      ? 'Thời gian dự kiến: ${schedule['timeLeft']}'
                                      : 'Thời gian còn lại: ${double.tryParse(schedule['timeLeft'].toString())?.toStringAsFixed(1) ?? schedule['timeLeft']} giây'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showCompletedSchedules(
      BuildContext context, List<Map<String, dynamic>> completedSchedules) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Lịch sử tưới nước',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              if (completedSchedules.isEmpty)
                Center(
                  child: Text(
                    'Chưa có lịch sử tưới nước.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: completedSchedules.map((schedule) {
                    return Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
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
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                schedule['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text('Khu vực tưới: ${schedule['area']}'),
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String isoString) {
    final dateTime = tz.TZDateTime.parse(tz.local, isoString);
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    return timeOfDay.format(context);
  }
}
