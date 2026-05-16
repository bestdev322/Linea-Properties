
import 'package:flutter/material.dart';


// Brand Colors
const Color primaryOrange = Color(0xFFE27252);
const Color secondaryText = Color(0xFF8E8E8E);

// Reusable Input Decoration to match image_8c8338.png
InputDecoration customInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    filled: true,
    fillColor: Colors.grey[50], // Very light grey background like the mockup
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    
    // Default border
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    
    // Border when the field is enabled but not clicked
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    
    // Border when the user clicks the field
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryOrange, width: 1.5),
    ),
    
    // Error border
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}