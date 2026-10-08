import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileProvider() {
    _loadProfileFromStorage();
  }

  // CREATE / INITIALIZE Profile
  Future<void> setProfile(UserProfile profile) async {
    _userProfile = profile;
    await _saveProfileToStorage();
    notifyListeners();
  }

  // READ Profile
  Future<void> _loadProfileFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString(AppConstants.keyUserProfile);
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(profileJson);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading stored profile: $e');
      }
    }
  }

  // UPDATE Profile Info (Name, Phone, Address, Bio, Photo)
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
    required String bio,
    File? newImageFile,
    Uint8List? newImageBytes,
  }) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String photoUrl = _userProfile!.photoUrl;

      // Upload image to Firebase Storage if selected
      if (newImageFile != null || newImageBytes != null) {
        final uploadedUrl = await _storageService.uploadProfileImage(
          userId: _userProfile!.id,
          imageFile: newImageFile,
          imageBytes: newImageBytes,
        );
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          photoUrl = uploadedUrl;
        }
      }

      // Update UserProfile model
      _userProfile = _userProfile!.copyWith(
        name: name,
        phone: phone,
        address: address,
        bio: bio,
        photoUrl: photoUrl,
      );

      await _saveProfileToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    }
  }

  // DELETE Profile / Reset Account Data
  Future<bool> deleteProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_userProfile != null) {
        await _storageService.deleteProfileImage(_userProfile!.id);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserProfile);

      _userProfile = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete profile: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveProfileToStorage() async {
    if (_userProfile == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserProfile, _userProfile!.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile: $e');
      }
    }
  }
}
