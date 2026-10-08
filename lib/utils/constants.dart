import 'package:flutter/material.dart';

class AppColors {
  // Blinkit signature palette
  static const Color primaryYellow = Color(0xFFF7C427);
  static const Color darkYellow = Color(0xFFE0AF11);
  static const Color primaryGreen = Color(0xFF0C831F);
  static const Color darkGreen = Color(0xFF086116);
  static const Color lightGreen = Color(0xFFE8F5E9);
  
  static const Color background = Color(0xFFF4F6F8);
  static const Color cardBg = Colors.white;
  
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF9E9E9E);
  
  static const Color border = Color(0xFFE0E0E0);
  static const Color discountBadge = Color(0xFF2563EB);
  static const Color orangeAccent = Color(0xFFFF6B00);
}

class AppConstants {
  static const String appName = 'atBlink';
  static const String appTagline = 'Everything delivered in 10 minutes';
  static const String currencySymbol = '₹';
  
  // REST API Endpoints
  static const String restApiBaseUrl = 'https://dummyjson.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
  
  // Storage Keys
  static const String keyUserProfile = 'atblink_user_profile';
  static const String keyCartItems = 'atblink_cart_items';
  static const String keyUserAuthToken = 'atblink_auth_token';
}
