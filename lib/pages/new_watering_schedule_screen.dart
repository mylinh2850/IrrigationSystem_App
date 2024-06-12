import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../watering_schedule_provider.dart';

class NewWateringScheduleScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNewScheduleCreated;

  NewWateringScheduleScreen({required this.onNewScheduleCreated});

  @override
  _NewWateringScheduleScreenState createState() => _NewWateringScheduleScreenState();
}

class _NewWateringScheduleScreenState extends State<NewWateringScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _fertilizer1 = '';
  String _fertilizer2 = '';
  String _fertilizer3 = '';
  String _water = '';
  String _area = '1';
  TimeOfDay? _selectedTime; // Thời gian được chọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Lịch Tưới Mới'),
        backgroundColor: Colors.green[400],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đặt tên lịch tưới mới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nhập tên lịch tưới',
                    ),
                    onSaved: (value) => _name = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Vui lòng nhập tên lịch tưới';
                      }
                      if (Provider.of<WateringScheduleProvider>(context, listen: false).checkDuplicateName(value)) {
                        return 'Tên lịch tưới đã tồn tại';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Số lượng phân bón 1 (ml)',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _fertilizer1 = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Vui lòng nhập số lượng phân bón 1';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Số lượng phân bón 2 (ml)',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _fertilizer2 = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Vui lòng nhập số lượng phân bón 2';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Số lượng phân bón 3 (ml)',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _fertilizer3 = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Vui lòng nhập số lượng phân bón 3';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Số lượng nước (ml)',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _water = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Vui lòng nhập số lượng nước';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Khu vực tưới (1/2/3)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _area,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ['1', '2', '3'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _area = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Thời gian hẹn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text(
                      _selectedTime == null
                          ? 'Chọn thời gian'
                          : 'Thời gian đã chọn: ${_selectedTime!.format(context)}',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          tz.TZDateTime? startTime;
                          if (_selectedTime != null) {
                            final now = tz.TZDateTime.now(tz.local);
                            startTime = tz.TZDateTime(
                              tz.local,
                              now.year,
                              now.month,
                              now.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            );
                            // Nếu thời gian đã chọn đã qua, đặt lịch vào ngày mai
                            if (startTime.isBefore(now)) {
                              startTime = startTime.add(Duration(days: 1));
                            }
                          }
                          Map<String, dynamic> newSchedule = {
                            'name': _name,
                            'area': _area,
                            'fertilizer1': _fertilizer1,
                            'fertilizer2': _fertilizer2,
                            'fertilizer3': _fertilizer3,
                            'waterAmount': _water,
                            'wateredAmount': '0',
                            'startTime': startTime?.toIso8601String(), // Thêm startTime vào lịch tưới
                          };
                          widget.onNewScheduleCreated(newSchedule);
                          Navigator.pop(context, true);
                        }
                      },
                      child: Text('BẮT ĐẦU TƯỚI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
