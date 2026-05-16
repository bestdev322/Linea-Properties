import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:linea_properties/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _dropAnimation;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // total animation time
    );

    // 1. Drop from top to center (0.0 → 0.0 offset)
    // Using Offset(0, -1) to Offset(0, 0) means vertical slide down
    _dropAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2), // start above screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // 2. Zoom in (scale 1.0 → 1.4)
    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 2.4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    // Start the animation
    _controller.forward();

    // After animation finishes, wait a tiny bit then navigate
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 200));
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (!mounted) return;

    if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthGate()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // white background
      body: Center(
        child: SlideTransition(
          position: _dropAnimation,
          child: ScaleTransition(
            scale: _zoomAnimation,
            child: Image.asset(
              'assets/linea_logo.png', // your logo asset
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
