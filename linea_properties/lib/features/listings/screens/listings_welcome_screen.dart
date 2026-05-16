// lib/features/listings/screens/listings_welcome_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'add_listing_flow.dart';

class ListingsWelcomeScreen extends StatelessWidget {
  const ListingsWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Section Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Listings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Middle Section (Your Image & Text)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Displaying your newly added asset image here
                Image.asset(
                  'assets/welcom_to_listing.png',
                  height: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if the image fails to load or path is incorrect
                    return const Icon(
                      Icons.add_business_outlined,
                      size: 120,
                      color: primaryOrange,
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "Create your property listing\nto reach verified tenants\nand buyers",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AddListingFlow(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}