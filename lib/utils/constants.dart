import 'package:flutter/material.dart';

class AppColors {
  // Blinkit signature palette
  static const Color primaryYellow = Color(0xFFF7C427);
  static const Color darkYellow = Color(0xFFE0AF11);
  static const Color primaryGreen = Color(0xFF0C831F);
  static const Color darkGreen = Color(0xFF086116);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color mintGreen = Color(0xFFDFF6E4);
  
  static const Color background = Color(0xFFF5F6F8);
  static const Color cardBg = Colors.white;
  
  static const Color textPrimary = Color(0xFF181C20);
  static const Color textSecondary = Color(0xFF545C66);
  static const Color textMuted = Color(0xFF8C95A0);
  
  static const Color border = Color(0xFFE6E8EC);
  static const Color discountBadge = Color(0xFF2563EB);
  static const Color orangeAccent = Color(0xFFFF6B00);
  static const Color surfaceWarm = Color(0xFFFFFBEA);

  // Modern Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF0E9323), Color(0xFF076618)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFF7C427)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cartGradient = LinearGradient(
    colors: [Color(0xFF0C831F), Color(0xFF085B17)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
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
