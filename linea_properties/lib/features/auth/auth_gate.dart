import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/main_navigation_container.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Use idTokenChanges() instead of authStateChanges()
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Not logged in
        if (user == null) {
          return const LoginScreen();
        }

        // Email not verified
        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        // Fully authenticated
        return const MainNavigationContainer();
      },
    );
  }
}