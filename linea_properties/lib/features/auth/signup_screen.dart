import 'dart:io'; // for Platform.isIOS

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../firebase_api/auth_service.dart';
import '../../firebase_api/user_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  final _userService = UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------- Email / Password SignUp ----------
  Future<void> _signup() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty) {
      _showError('Please enter your full name.');
      return;
    }
    if (email.isEmpty) {
      _showError('Please enter your email.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Signup failed. Please try again.');
      }

      // ✅ Immediately pop to root – AuthGate will now show VerifyEmailScreen
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      // ✅ Non‑critical tasks (don't throw if they fail)
      try {
        await user.sendEmailVerification();
      } catch (e) {
        print('Failed to send verification email: $e');
        // You can optionally show a snackbar from here, but the user is already
        // on the verification screen, so it's not strictly necessary.
      }

      try {
        await _userService.ensureUserProfile(
          authUser: user,
          fullName: fullName,
        );
      } catch (e) {
        print("PROFILE ERROR: $e");
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Signup failed.');
    } catch (e) {
      print("SIGNUP ERROR: $e");
      _showError('Signup failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- Google Sign‑In ----------
  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Google sign-in failed. Please try again.');
      }

      // ✅ Pop to root so AuthGate takes over
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      // Non‑critical profile creation
      try {
        await _userService.ensureUserProfile(authUser: user);
      } catch (e) {
        print("PROFILE ERROR: $e");
      }
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- Apple Sign‑In (only on iOS) ----------
  Future<void> _signUpWithApple() async {
    // Add your Apple sign‑in logic here.
    // This method will only be called on iOS, thanks to the Platform check below.
    // For example:
    // final credential = await _authService.signInWithApple();
    // final user = credential.user;
    // if (user != null && mounted) {
    //   Navigator.of(context).popUntil((route) => route.isFirst);
    // }
    // Don't forget to pop to root on success.
    // For now, you can leave it empty or show a “coming soon” message.
  }

  // ---------- Error Handling ----------
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo
              Image.asset(
                'assets/linea_logo.png',
                height: 80,
              ),
              const SizedBox(height: 30),
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your detail to Signup",
                style: TextStyle(color: secondaryText, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Full Name Field
              _buildLabel("Full Name"),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                decoration: customInputDecoration("Abdullah Nadeem"),
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildLabel("Email"),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: customInputDecoration("Enter your Email"),
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildLabel("Password"),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: customInputDecoration("Enter your password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Signup",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("or continue with", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              const SizedBox(height: 30),

              // Social Icons – Apple only on iOS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    'assets/google_icon.png',
                    onTap: _isLoading ? null : _signUpWithGoogle,
                  ),
                  // Apple button is only shown on iOS
                  if (Platform.isIOS) ...[
                    const SizedBox(width: 20),
                    _socialButton(
                      'assets/apple_icon.png',
                      onTap: _isLoading ? null : _signUpWithApple,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 30),

              // Login Redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _socialButton(String assetPath, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.asset(assetPath, height: 24),
      ),
    );
  }
}