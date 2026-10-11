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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> _executeAuth(
    ProfileProvider profileProvider,
    Future<UserProfile?> Function() authAction, {
    String? cancelMessage,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final userProfile = await authAction();
      if (userProfile != null) {
        await profileProvider.setProfile(userProfile);
        _setLoading(false);
        return true;
      }
      if (cancelMessage != null) _errorMessage = cancelMessage;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
    return false;
  }

  /// Google OAuth Sign-In
  Future<bool> signInWithGoogle(ProfileProvider profileProvider) =>
      _executeAuth(
        profileProvider,
        _authService.signInWithGoogle,
        cancelMessage: 'Google Sign-In was cancelled or failed.',
      );

  /// Register with Email & Password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required ProfileProvider profileProvider,
  }) =>
      _executeAuth(
        profileProvider,
        () => _authService.registerWithEmail(email, password, name),
      );

  /// Sign In with Email & Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required ProfileProvider profileProvider,
  }) =>
      _executeAuth(
        profileProvider,
        () => _authService.signInWithEmail(email, password),
      );

  /// Guest Sign In
  Future<bool> signInAsGuest(ProfileProvider profileProvider) =>
      _executeAuth(
        profileProvider,
        () async => _authService.signInAsGuest(),
      );

  /// Sign Out
  Future<void> signOut(ProfileProvider profileProvider) async {
    await _authService.signOut();
    await profileProvider.deleteProfile();
    notifyListeners();
  }
}
