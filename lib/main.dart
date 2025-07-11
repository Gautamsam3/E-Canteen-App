import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Canteen',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(appState: AppState()),
    );
  }
}
