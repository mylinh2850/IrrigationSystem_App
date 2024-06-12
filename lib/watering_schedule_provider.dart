import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class WateringScheduleProvider with ChangeNotifier {
  bool _hasCurrentSchedule = false;
  Map<String, dynamic> _currentSchedule = {};
  List<Map<String, dynamic>> _waitingSchedules = [];
  List<Map<String, dynamic>> _completedSchedules = [];

  double _temperature = 0.0;
  double _humidity = 0.0;
  int _totalTime = 0;
  int _elapsedTime = 0;
  Timer? _timer;
  Timer? _scheduleCheckTimer;
  bool _isConnected = false; // Track the connection state

  bool get hasCurrentSchedule => _hasCurrentSchedule;
  Map<String, dynamic> get currentSchedule => _currentSchedule;
  List<Map<String, dynamic>> get waitingSchedules => _waitingSchedules;
  List<Map<String, dynamic>> get completedSchedules => _completedSchedules;

  double get temperature => _temperature;
  double get humidity => _humidity;
  int get totalTime => _totalTime;
  int get elapsedTime => _elapsedTime;

  final String _adafruitUsername = 'BasintonDinh';
  final String _adafruitApiKey = 'aio_HULv39894ymd5YV3ZvUdHQdcieqP';
  final String _feedName = 'iot-project.app';
  final String _managementFeedName =
      'iot-project.management'; // Feed for confirmation
  final String _sensorFeedName = 'iot-project.gateway';
  final String _server = 'io.adafruit.com';

  MqttServerClient? _client;

  WateringScheduleProvider() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    _setupMqttClient();
    connect();
    _startScheduleCheckTimer(); // Bắt đầu kiểm tra định kỳ
  }

  void _setupMqttClient() {
    _client = MqttServerClient.withPort(_server, 'flutter_client', 1883);
    _client!.keepAlivePeriod = 60;
    _client!.logging(on: true);
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onSubscribed = _onSubscribed;
    _client!.onSubscribeFail = _onSubscribeFail;
    _client!.onUnsubscribed = _onUnsubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs(_adafruitUsername, _adafruitApiKey)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;
  }

  Future<void> connect() async {
    if (_isConnected) return; // Do not reconnect if already connected
    try {
      print('Connecting to MQTT broker...');
      await _client!.connect();
      _isConnected = true; // Update connection state
      _client!.subscribe(
          '$_adafruitUsername/feeds/$_sensorFeedName', MqttQos.atMostOnce);
      _client!.subscribe('$_adafruitUsername/feeds/$_managementFeedName',
          MqttQos.atMostOnce); // Subscribe to management feed
      _client!.updates!.listen(_onMessage);
    } catch (e) {
      print('Exception: $e');
      disconnect();
    }
  }

  void disconnect() {
    // Do not disconnect to maintain the connection
    // _client?.disconnect();
    // _isConnected = false; // Update connection state
  }

  void _onConnected() {
    print('Connected');
  }

  void _onDisconnected() {
    print('Disconnected');
    // Attempt to reconnect if disconnected
    _isConnected = false;
    connect();
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

  void _onUnsubscribed(String? topic) {
    print('Unsubscribed from $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage message = event[0].payload as MqttPublishMessage;
    final String payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
    print('Received message: $payload from topic: ${event[0].topic}');

    try {
      final Map<String, dynamic> data = jsonDecode(payload);

      if (event[0].topic == '$_adafruitUsername/feeds/$_sensorFeedName') {
        _temperature = data['temperature'] / 100;
        _humidity = data['humidity'] / 100;

        print(
            'Updated values: Temperature = $_temperature, Humidity = _humidity');
        notifyListeners();
      } else if (event[0].topic ==
          '$_adafruitUsername/feeds/$_managementFeedName') {
        // Handle confirmation message from management feed
        if (data['status'] == 'confirmed' &&
            data['schedule_name'] == _currentSchedule['name']) {
          // Update total time based on received total_time
          _totalTime =
              (data['total_time'] * 1000).toInt(); // Convert to milliseconds
          _currentSchedule['timeLeft'] = (_totalTime / 1000)
              .toStringAsFixed(1); // Update to one decimal place
          _executeSchedule(_currentSchedule);
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  Future<void> _sendScheduleToAdafruit(Map<String, dynamic> schedule) async {
    print('Preparing to send schedule to Adafruit: $schedule');
    if (_client == null ||
        _client!.connectionStatus!.state != MqttConnectionState.connected) {
      print('Client not connected. Attempting to connect...');
      await connect();
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      final String topic = '$_adafruitUsername/feeds/$_feedName';
      final String payload = jsonEncode({
        'name': schedule['name'],
        'area': schedule['area'],
        'fertilizer1': schedule['fertilizer1'],
        'fertilizer2': schedule['fertilizer2'],
        'fertilizer3': schedule['fertilizer3'],
        'waterAmount': schedule['waterAmount'],
      });

      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(payload);

      print('Publishing message to topic: $topic with payload: $payload');
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    } else {
      print('Failed to connect to MQTT broker');
    }
  }

  void addSchedule(Map<String, dynamic> newSchedule) {
    if (checkDuplicateName(newSchedule['name'])) {
      return;
    }

    int fertilizer1 = int.parse(newSchedule['fertilizer1']);
    int fertilizer2 = int.parse(newSchedule['fertilizer2']);
    int fertilizer3 = int.parse(newSchedule['fertilizer3']);
    int waterAmount = int.parse(newSchedule['waterAmount']);
    int totalVolume = fertilizer1 + fertilizer2 + fertilizer3 + waterAmount;

    newSchedule['progress'] = 0;
    newSchedule['timeLeft'] = 'đang tính toán'; // Update this line
    newSchedule['createdTime'] = tz.TZDateTime.now(tz.local).toIso8601String();
    newSchedule['totalVolume'] = totalVolume.toString();

    if (_hasCurrentSchedule) {
      newSchedule['timeLeft'] = 'đang chờ';
      _waitingSchedules.add(newSchedule);
      _waitingSchedules.sort((a, b) {
        DateTime aTime = a['startTime'] != null
            ? tz.TZDateTime.parse(tz.local, a['startTime'])
            : DateTime.now();
        DateTime bTime = b['startTime'] != null
            ? tz.TZDateTime.parse(tz.local, b['startTime'])
            : DateTime.now();
        return aTime.compareTo(bTime);
      });
      notifyListeners();
    } else {
      if (newSchedule['startTime'] != null) {
        DateTime startTime = tz.TZDateTime.parse(tz.local, newSchedule['startTime']);
        Duration delay = startTime.difference(tz.TZDateTime.now(tz.local));
        print('Thời gian hiện tại của app: ${tz.TZDateTime.now(tz.local)}');
        print('Thời gian tôi đặt lịch: $startTime');
        print('Thời gian chờ: $delay');
        if (delay.isNegative) {
          // Nếu thời gian đã chọn đã qua, bắt đầu ngay lập tức
          _currentSchedule = newSchedule;
          _currentSchedule['wateredAmount'] = '0';
          _hasCurrentSchedule = true;
          _sendScheduleToAdafruit({
            'name': newSchedule['name'],
            'area': newSchedule['area'],
            'fertilizer1': newSchedule['fertilizer1'],
            'fertilizer2': newSchedule['fertilizer2'],
            'fertilizer3': newSchedule['fertilizer3'],
            'waterAmount': newSchedule['waterAmount'],
          });
          notifyListeners();
        } else {
          // Nếu thời gian chưa tới, thêm vào danh sách chờ
          newSchedule['timeLeft'] = 'đang chờ';
          _waitingSchedules.add(newSchedule);
          _waitingSchedules.sort((a, b) {
            DateTime aTime = a['startTime'] != null
                ? tz.TZDateTime.parse(tz.local, a['startTime'])
                : DateTime.now();
            DateTime bTime = b['startTime'] != null
                ? tz.TZDateTime.parse(tz.local, b['startTime'])
                : DateTime.now();
            return aTime.compareTo(bTime);
          });
          notifyListeners();
        }
      } else {
        // Bắt đầu ngay lập tức nếu không có thời gian bắt đầu
        _currentSchedule = newSchedule;
        _currentSchedule['wateredAmount'] = '0';
        _hasCurrentSchedule = true;
        _sendScheduleToAdafruit({
          'name': newSchedule['name'],
          'area': newSchedule['area'],
          'fertilizer1': newSchedule['fertilizer1'],
          'fertilizer2': newSchedule['fertilizer2'],
          'fertilizer3': newSchedule['fertilizer3'],
          'waterAmount': newSchedule['waterAmount'],
        });
        notifyListeners();
      }
    }
  }

  void _startScheduleCheckTimer() {
    _scheduleCheckTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkScheduledTasks();
    });
  }

  void _checkScheduledTasks() {
    DateTime now = tz.TZDateTime.now(tz.local);
    if (!_hasCurrentSchedule && _waitingSchedules.isNotEmpty) {
      _waitingSchedules.sort((a, b) {
        DateTime aTime = a['startTime'] != null
            ? tz.TZDateTime.parse(tz.local, a['startTime'])
            : now;
        DateTime bTime = b['startTime'] != null
            ? tz.TZDateTime.parse(tz.local, b['startTime'])
            : now;
        return aTime.compareTo(bTime);
      });

      for (var schedule in _waitingSchedules) {
        DateTime scheduleTime = tz.TZDateTime.parse(tz.local, schedule['startTime']);
        print('Thời gian hiện tại của app: $now');
        print('Thời gian tôi đặt lịch: $scheduleTime');
        print('Thời gian chờ: ${scheduleTime.difference(now)}');
        if (now.isAfter(scheduleTime) || now.isAtSameMomentAs(scheduleTime)) {
          _currentSchedule = schedule;
          _waitingSchedules.remove(schedule);
          _currentSchedule['wateredAmount'] = '0';
          _hasCurrentSchedule = true;
          _sendScheduleToAdafruit({
            'name': schedule['name'],
            'area': schedule['area'],
            'fertilizer1': schedule['fertilizer1'],
            'fertilizer2': schedule['fertilizer2'],
            'fertilizer3': schedule['fertilizer3'],
            'waterAmount': schedule['waterAmount'],
          });
          notifyListeners();
          break;
        }
      }
    }
  }

  void _executeSchedule(Map<String, dynamic> schedule) {
    print('Executing schedule: $schedule');

    _elapsedTime = 0;
    notifyListeners();

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _elapsedTime += 100;
      _currentSchedule['progress'] = (_elapsedTime / _totalTime) * 100;
      _currentSchedule['timeLeft'] = (_totalTime - _elapsedTime) / 1000;
      int totalVolume = int.parse(schedule['totalVolume']);
      _currentSchedule['wateredAmount'] =
          ((totalVolume * (_elapsedTime / _totalTime))
              .toStringAsFixed(0)); // Update watered amount in ml

      if (_elapsedTime >= _totalTime) {
        timer.cancel();
        completeCurrentSchedule();
      }
      notifyListeners();
    });
  }

  void completeCurrentSchedule() {
    if (_hasCurrentSchedule) {
      _currentSchedule['completedTime'] = tz.TZDateTime.now(tz.local).toIso8601String();
      _completedSchedules.add(_currentSchedule);
      _hasCurrentSchedule = false;
      _checkScheduledTasks(); // Check lại các lịch hẹn sau khi hoàn thành lịch hiện tại
    }
  }

  bool checkDuplicateName(String name) {
    if (_hasCurrentSchedule && _currentSchedule['name'] == name) {
      return true;
    }
    for (var schedule in _waitingSchedules) {
      if (schedule['name'] == name) {
        return true;
      }
    }
    for (var schedule in _completedSchedules) {
      if (schedule['name'] == name) {
        return true;
      }
    }
    return false;
  }

  void resetSchedule() {
    _hasCurrentSchedule = false;
    _currentSchedule = {};
    _waitingSchedules = [];
    _completedSchedules = [];
    notifyListeners();
  }
}
