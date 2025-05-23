import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:univents/screens/dashboard.dart';
import 'package:univents/screens/login.dart';
import 'package:univents/screens/item.dart';
import 'package:univents/screens/chat.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
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
        '/home': (context) => Dashboard(),
        '/chat': (context) => Chat(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/item') {
          final item = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => Item(item: item),
          );
        }
        return null; 
      }
    );
  }
}
