import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart'; // import 'package:linea_app/core/theme/app_theme.dart'

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/linea_logo.png', // Main Logo verbatim reference from image_4.png
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          _buildLanguageSelector(),
          const SizedBox(width: 8),
          _buildCircleActionButton(Icons.wallet_outlined),
          const SizedBox(width: 8),
          _buildNotificationButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Text("Search apartment,location", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryFilter("All", Icons.home_outlined, isSelected: true),
                  const SizedBox(width: 12),
                  _buildCategoryFilter("Apartments", Icons.apartment_outlined),
                  const SizedBox(width: 12),
                  _buildCategoryFilter("Houses", Icons.house_outlined),
                  const SizedBox(width: 12),
                  _buildCategoryFilter("Land", Icons.landscape_outlined),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Listings Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Featured Listings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),

            // Featured Listing Card
            _buildFeaturedCard(),
            const SizedBox(height: 24),

            // Popular Areas Header
            const Text("Popular Areas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Popular Areas List
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAreaCard("Douala", "assets/solar_buliding.png"),
                  const SizedBox(width: 16),
                  _buildAreaCard("Yaoundé", "assets/proicons_bell.png"),
                ],
              ),
            ),
            const SizedBox(height: 100), // Spacing for bottom navigation and floating button
          ],
        ),
      ),
      // // Floating Plus Button
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: primaryOrange,
      //   elevation: 2,
      //   child: const Icon(Icons.add, color: Colors.white, size: 30),
      // ),
      // Bottom Navigation Bar
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.white,
      //   shape: const CircularNotchedRectangle(),
      //   notchMargin: 8,
      //   child: Container(
      //     height: 70,
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         // Use custom icons here for best match, example with generic:
      //         _buildBottomNavItem("Home", Icons.home_filled, isSelected: true),
      //         _buildBottomNavItem("Search", Icons.search),
      //         const SizedBox(width: 48), // Space for floating action button
      //         _buildBottomNavItem("Chat", Icons.chat_bubble_outline),
      //         _buildBottomNavItem("Profile", Icons.person_outline_sharp),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  // --- Widget Builders ---

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Image.asset('assets/uk_flag.png', height: 20),
        const SizedBox(width: 8),
        const Text("EN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
      ],
    );
  }

  Widget _buildCircleActionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black87, size: 24),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          const Icon(Icons.notifications_none, color: Colors.black87, size: 24),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(radius: 6, backgroundColor: primaryOrange, child: const Text("1", style: TextStyle(color: Colors.white, fontSize: 8))),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(String label, IconData icon, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryOrange : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image with tags
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/modern3.jpg', fit: BoxFit.cover, height: 180, width: double.infinity),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildTag("For Rent", isSelected: false),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildTag("40,000 CFA", isSelected: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Details
            Row(
              children: [
                Text("Modern 3-Bed Apartment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryOrange)),
                SizedBox(width: 10),
                // Promoted tag
                _buildTag("Promoted", isSelected: true, fontSize: 10),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text("Douala", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmenity("3 Bedrooms", Icons.bed_outlined),
                _buildAmenity("Bathrooms", Icons.bathtub_outlined),
                _buildAmenity("2200 m²", Icons.aspect_ratio_outlined),
              ],
            ),
            const SizedBox(height: 20),
            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Schedule Viewing - 500 CFA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {required bool isSelected, double fontSize = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? primaryOrange : Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : primaryOrange,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildAmenity(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildAreaCard(String city, String assetPath) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withAlpha(51),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              city,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomNavItem(String label, IconData icon, {bool isSelected = false}) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Icon(icon, color: isSelected ? primaryOrange : Colors.grey, size: 24),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: TextStyle(color: isSelected ? primaryOrange : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
  //       ),
  //     ],
  //   );
  // }
}
