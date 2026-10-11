import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirestoreService _firestoreService = FirestoreService();
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
    _firestoreService.saveUserLoginInfo(profile);
    notifyListeners();
  }

  // READ Profile
  Future<void> _loadProfileFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(AppConstants.keyUserProfile);
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(profileJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored profile: $e');
    }
  }

  // UPDATE Profile Info
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

      _userProfile = _userProfile!.copyWith(
        name: name,
        phone: phone,
        address: address,
        bio: bio,
        photoUrl: photoUrl,
      );

      await _saveProfileToStorage();
      _firestoreService.saveUserLoginInfo(_userProfile!);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Quick Switch Delivery Address
  Future<void> updateDeliveryAddress(String newAddress) async {
    if (_userProfile == null) {
      _userProfile = UserProfile(
        id: 'guest',
        name: 'Guest User',
        email: 'user@atblink.com',
        address: newAddress,
      );
    } else {
      _userProfile = _userProfile!.copyWith(address: newAddress);
    }
    await _saveProfileToStorage();
    _firestoreService.saveUserLoginInfo(_userProfile!);
    notifyListeners();
  }

  // DELETE Profile / Reset Account Data
  Future<bool> deleteProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_userProfile != null) {
        await _storageService.deleteProfileImage(_userProfile!.id);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserProfile);
      _userProfile = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProfileToStorage() async {
    if (_userProfile == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserProfile, _userProfile!.toJson());
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }
}
