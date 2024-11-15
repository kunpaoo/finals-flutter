import 'package:flutter/material.dart';
import 'package:univents/screens/dashboard.dart';
import 'package:univents/screens/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const Dashboard()
      },
    );
  }
}
