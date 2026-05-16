// lib/features/home/profile_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../firebase_api/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final User? user = auth.currentUser;
     String? name = user?.displayName;
     String? email = user?.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header
            _buildSection([
              ListTile(
                leading: const CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/user_profile.png')),
                title:  Text( name!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:  Text(email!, style: TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          
              ),
            ]),

            const SizedBox(height: 16),
            _buildSection([
              _profileTile(Icons.qr_code_scanner, "Scan QR"),
            ]),

            const SizedBox(height: 16),
            _buildSection([
              _profileTile(Icons.wallet_outlined, "My Wallet"),
            ]),

            const SizedBox(height: 16),
            _buildSection([
              _profileTile(Icons.apartment, "My Properties"),
              _profileTile(Icons.list_alt, "My Listings"),
              _profileTile(Icons.favorite_border, "Favourite Properties"),
            ]),

            const SizedBox(height: 16),
            _buildSection([
              _profileTile(Icons.notifications_none, "Notifications", isSwitch: true),
              _profileTile(Icons.password, "Password Settings"),
              _profileTile(Icons.language, "Language Settings", isFunctional: true, onTap: () {
                _showLanguageDialog(context);
              }),
            ]),

            const SizedBox(height: 16),
            _buildSection([
              _profileTile(Icons.help_outline, "Help Centre"),
              _profileTile(Icons.description_outlined, "Terms of Services"),
              _profileTile(Icons.privacy_tip_outlined, "Privacy Policy"),
            ]),

            const SizedBox(height: 16),
            _buildSection([
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await auth.logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
              _profileTile(Icons.delete_outline, "Delete your account", color: Colors.red),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
void getUserDetails() {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Basic account information
    String? email = user.email;
    String? username = user.displayName;
    String uid = user.uid;

    print("Email: $email, Username: $username, UID: $uid");
  } else {
    print("No user is currently signed in.");
  }
}
  Widget _profileTile(IconData icon, String title, {
    bool isSwitch = false, 
    bool isFunctional = false, 
    VoidCallback? onTap,
    Color color = Colors.black,
  }) {
    return Builder(builder: (context) {
      return ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: isSwitch 
          ? Switch(value: true, onChanged: (v) {}, activeColor: primaryOrange)
          : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isFunctional ? onTap : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Will be functional in upcoming milestones"))
          );
        },
      );
    });
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("English"), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text("Français"), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}