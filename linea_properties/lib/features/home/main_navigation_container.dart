import 'package:flutter/material.dart';
import 'package:linea_properties/features/home/home_screen.dart';
import '../../core/theme/app_theme.dart';
//import '../../firebase_api/auth_service.dart';
import 'profile_screen.dart'; // We will create this below
import '../listings/screens/add_listing_flow.dart';
import '../listings/screens/listings_welcome_screen.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(), // Your existing Home UI code
    const Center(child: Text("Search: Under implementation", style: TextStyle(fontSize: 18))),
    const Center(child: Text("Chat: Under implementation", style: TextStyle(fontSize: 18))),
    const ProfileScreen(), // The new Profile UI
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex == 4 ? 3 : _selectedIndex], // Logic to handle FAB gap
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Slide the Welcome Page up from the bottom like a sheet
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ListingsWelcomeScreen(),
              fullscreenDialog: true, // Native modal sheet slide-up
            ),
          );
        },
        backgroundColor: primaryOrange,
        shape: const CircleBorder(), // Clean circular button
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_outlined, "Home"),
            _buildNavItem(1, Icons.search, "Search"),
            const SizedBox(width: 40), // Gap for FAB
            _buildNavItem(2, Icons.chat_bubble_outline, "Chat"),
            _buildNavItem(3, Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primaryOrange : Colors.grey),
            Text(label, style: TextStyle(color: isSelected ? primaryOrange : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // void _showSnackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  // }
}