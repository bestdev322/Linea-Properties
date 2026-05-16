import 'package:flutter/material.dart';
import 'package:linea_properties/features/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// Import your login screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LineaApp());
}

class LineaApp extends StatelessWidget {
  const LineaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFE27252),
        scaffoldBackgroundColor: Colors.white,
      ),
      
      // Start with the Login Screen
      home: const SplashScreen(), // 👈 always start with splash
    );
  }
}