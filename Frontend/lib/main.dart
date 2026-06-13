import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.dark,
  ));
  final prefs    = await SharedPreferences.getInstance();
  final workerId = prefs.getInt('worker_id');
  runApp(RozgarShieldApp(workerId: workerId));
}

class RozgarShieldApp extends StatelessWidget {
  final int? workerId;
  const RozgarShieldApp({super.key, this.workerId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      'RozgarShield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE8EDFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A2E6E),
        ),
        useMaterial3: true,
      ),
      home: workerId != null
        ? HomeScreen(workerId: workerId!)
        : const WelcomeScreen(),
    );
  }
}
