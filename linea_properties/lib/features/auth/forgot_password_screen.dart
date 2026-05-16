import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../firebase_api/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      _showMessage('Password reset email sent. Please check your inbox.');
    } on AuthFailure catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Failed to send reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Forgot Password?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryOrange)),
            const SizedBox(height: 8),
            const Text("Enter your email to receive a recovery code", textAlign: TextAlign.center, style: TextStyle(color: secondaryText)),
            const SizedBox(height: 40),
            const Align(alignment: Alignment.centerLeft, child: Text("Email", style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: customInputDecoration("example123@gmail.com"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isLoading ? null : _sendResetEmail,
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
                        "Send Code",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back to Login", style: TextStyle(color: primaryOrange))),
          ],
        ),
      ),
    );
  }
}

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter OTP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryOrange)),
            const SizedBox(height: 8),
            const Text("Enter OTP sent to ab***111@gmail.com", textAlign: TextAlign.center, style: TextStyle(color: secondaryText)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildOtpBox(context)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {}, // Navigate to Reset Password
                child: const Text("Verify OTP", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("00:53 Resend code", style: TextStyle(color: secondaryText)),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: const TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(border: InputBorder.none, counterText: ""),
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/success_check.png', height: 100),
          const SizedBox(height: 20),
          const Text("Password changed Successfully", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text("Back to login", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("login", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}
