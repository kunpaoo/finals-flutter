import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    print("im here");
    return const Scaffold(
    backgroundColor: Colors.white, 
    body: Center(
      child: const Text(
        "You're logged in",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black, 
        ),
      ),
    ),
  );
  }
}
