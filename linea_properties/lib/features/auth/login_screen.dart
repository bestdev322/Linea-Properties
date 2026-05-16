import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../firebase_api/auth_service.dart';
import '../../firebase_api/user_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  final _userService = UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------- Email / Password Login ----------
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Please enter your email.');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      // ✅ AuthGate handles navigation automatically
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed.');
    } catch (e) {
      _showError('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- Forgot Password ----------
  // Future<void> _forgotPassword() async {
  //   final email = _emailController.text.trim();

  //   if (email.isEmpty) {
  //     _showError('Please enter your email address first.');
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     await _authService.sendPasswordResetEmail(email);
  //     if (!mounted) return;
  //     _showMessage('Password reset email sent. Check your inbox.');
  //   } on FirebaseAuthException catch (e) {
  //     _showError(e.message ?? 'Failed to send reset email.');
  //   } catch (e) {
  //     _showError('Failed to send reset email. Please try again.');
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // ---------- Google Sign‑In ----------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user == null) throw const AuthFailure('Google sign-in failed.');

      // Ensure profile exists
      try {
        await _userService.ensureUserProfile(authUser: user);
      } catch (_) {}
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- Error Handling ----------
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // void _showMessage(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  // }

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
                "Login",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your details to login",
                style: TextStyle(color: secondaryText, fontSize: 16),
              ),
              const SizedBox(height: 40),

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

              // ✅ Forgot Password button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(
                           // initialEmail: _emailController.text.trim(),
                          ),
                        ),
                      );
                    },

                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: primaryOrange),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                          "Login",
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

              // Social Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    'assets/google_icon.png',
                    onTap: _isLoading ? null : _signInWithGoogle,
                  ),
                  // Apple button can be added here (only on iOS)
                ],
              ),

              const SizedBox(height: 40),

              // Signup Redirect (corrected with push)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
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