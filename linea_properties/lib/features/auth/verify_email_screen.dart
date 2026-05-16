import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../firebase_api/auth_service.dart';
import '../../firebase_api/user_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _authService = AuthService();
  final _userService = UserService();

  bool _isLoading = false;

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    try {
      await _authService.sendEmailVerification();
      if (!mounted) return;
      _showMessage('Verification email sent. Please check your inbox.');
    } catch (e) {
      _showMessage('Failed to send verification email.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshStatus() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        _showMessage('Session expired. Please login again.');
        return;
      }

      await user.reload();

      final refreshedUser = _authService.currentUser;
      if (refreshedUser == null) {
        _showMessage('Session expired. Please login again.');
        return;
      }

      try {
        await _userService.ensureUserProfile(authUser: refreshedUser);
      } catch (_) {}

      if (refreshedUser.emailVerified) {
        // Force token refresh → triggers AuthGate stream
        await refreshedUser.getIdToken(true);

        if (mounted) {
          _showMessage('Email verified successfully!');
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        _showMessage('Email not verified yet. Please check your inbox.');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'An error occurred.');
    } catch (e) {
      debugPrint('_refreshStatus error: $e');
      _showMessage('Failed to refresh verification status.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await _authService.logout();
    } catch (_) {
      _showMessage('Logout failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/linea_logo.png', height: 80),
              const SizedBox(height: 20),
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email.isEmpty
                    ? 'We sent a verification link to your email.'
                    : 'We sent a verification link to:\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(color: secondaryText, fontSize: 15),
              ),
              const SizedBox(height: 30),
              const Text(
                'Open the email and click the verification link, then come back and tap "I verified".',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryText),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _refreshStatus,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'I verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _resend,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Resend email',
                    style: TextStyle(
                      color: primaryOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isLoading ? null : _logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(color: secondaryText),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}