import 'package:flutter/foundation.dart';

import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import 'profile_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Google OAuth Sign-In
  Future<bool> signInWithGoogle(ProfileProvider profileProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserProfile? userProfile = await _authService.signInWithGoogle();
      if (userProfile != null) {
        await profileProvider.setProfile(userProfile);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Google Sign-In was cancelled or failed.';
      }
    } catch (e) {
      _errorMessage = 'Google Sign-In Error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Register with Email & Password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required ProfileProvider profileProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = await _authService.registerWithEmail(email, password, name);
      if (userProfile != null) {
        await profileProvider.setProfile(userProfile);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Registration error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required ProfileProvider profileProvider,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = await _authService.signInWithEmail(email, password);
      if (userProfile != null) {
        await profileProvider.setProfile(userProfile);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Sign In error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Guest Sign In
  Future<bool> signInAsGuest(ProfileProvider profileProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = await _authService.signInAsGuest();
      await profileProvider.setProfile(userProfile);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Guest Sign-In error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign Out
  Future<void> signOut(ProfileProvider profileProvider) async {
    await _authService.signOut();
    await profileProvider.deleteProfile();
    notifyListeners();
  }
}
