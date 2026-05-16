import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/listing_model.dart';

class PromotePaymentScreen extends StatefulWidget {
  final ListingModel listing;
  const PromotePaymentScreen({super.key, required this.listing});

  @override
  State<PromotePaymentScreen> createState() => _PromotePaymentScreenState();
}

class _PromotePaymentScreenState extends State<PromotePaymentScreen> {
  // Mock wallet balance for testing. 
  // Change to 200 to see the "Insufficient Balance / Topup Wallet" state!
  final double currentWalletBalance = 50000; 
  final double promotionFee = 5000;

  @override
  Widget build(BuildContext context) {
    bool hasSufficientBalance = currentWalletBalance >= promotionFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Promote Listing", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Promotion Fee:", style: TextStyle(color: Colors.grey)),
                Text("${promotionFee.toInt()} CFA", style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Duration:", style: TextStyle(color: Colors.grey)),
                Text("10 Days", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payable Now:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${promotionFee.toInt()} CFA", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 48),
            
            // Wallet Balance Checker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Wallet Balance", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${currentWalletBalance.toInt()} CFA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // Green if enough, Red if insufficient
                      color: hasSufficientBalance ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (hasSufficientBalance) {
                // Publish listing logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment successful. Listing Promoted!"), backgroundColor: Colors.green),
                );
                // Pop back to home (closes payment and flow)
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                // Navigate to Top up wallet screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Redirecting to Top Up..."), backgroundColor: primaryOrange),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              hasSufficientBalance ? "Pay & List" : "Topup Wallet",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}