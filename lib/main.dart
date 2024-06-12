import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'watering_schedule_provider.dart';
import 'pages/home_screen.dart';
import 'pages/second_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/new_watering_schedule_screen.dart';
import 'pages/about_screen.dart';
import 'pages/account_settings_screen.dart';
import 'pages/change_password_screen.dart';
import 'pages/login_screen.dart';
import 'pages/view_user_info_screen.dart';
import 'widgets/custom_bottom_navigation_bar.dart';

void main() {
  // Initialize time zone database
  tz.initializeTimeZones();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WateringScheduleProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Quản lý nông nghiệp',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Hiển thị khi đang tải trạng thái đăng nhập
          } else if (snapshot.hasData && snapshot.data == true) {
            return MainScreen(); // Màn hình chính nếu đã đăng nhập
          } else {
            return LoginScreen(); // Màn hình đăng nhập nếu chưa đăng nhập hoặc đã hết thời gian đăng nhập
          }
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/second': (context) => SecondScreen(),
        '/settings': (context) => SettingsScreen(),
        '/new': (context) => NewWateringScheduleScreen(
          onNewScheduleCreated: (schedule) {
            Provider.of<WateringScheduleProvider>(context, listen: false).addSchedule(schedule);
          },
        ),
        '/about': (context) => AboutScreen(),
        '/account': (context) => AccountSettingsScreen(
          name: '',
          gender: '',
          email: '',
          phone: '',
          onUpdate: (name, gender, email, phone) {},
        ),
        '/change_password': (context) => ChangePasswordScreen(),
        '/login': (context) => LoginScreen(),
        '/view_user_info': (context) => ViewUserInfoScreen(),
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      return false;
    }

    int loginTimestamp = prefs.getInt('loginTimestamp') ?? 0;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedTime = currentTime - loginTimestamp;

    // Kiểm tra nếu đã qua 2 phút (120,000 milliseconds)
    if (elapsedTime > 120000) {
      await prefs.setBool('isLoggedIn', false);
      return false;
    }

    return true;
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SecondScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
