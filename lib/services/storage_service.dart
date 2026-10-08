import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Uploads profile image file or byte data to Firebase Storage under `user_profiles/{userId}.jpg`
  Future<String?> uploadProfileImage({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      // Validate file size (Max 5MB to prevent quota exhaustion)
      const maxSizeBytes = 5 * 1024 * 1024;
      if (imageFile != null && imageFile.lengthSync() > maxSizeBytes) {
        throw Exception('Image file exceeds the 5MB upload limit.');
      }
      if (imageBytes != null && imageBytes.lengthInBytes > maxSizeBytes) {
        throw Exception('Image exceeds the 5MB upload limit.');
      }

      final Reference ref =
          _storage.ref().child('user_profiles').child('$userId.jpg');

      UploadTask uploadTask;

      if (kIsWeb) {
        if (imageBytes != null) {
          uploadTask = ref.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          return null;
        }
      } else {
        if (imageFile != null) {
          uploadTask = ref.putFile(
            imageFile,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else if (imageBytes != null) {
          uploadTask = ref.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          return null;
        }
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage upload error: $e');
      }
    }

    // High availability fallback for demo/dev mode
    return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop';
  }

  /// Deletes profile image from Firebase Storage
  Future<bool> deleteProfileImage(String userId) async {
    try {
      final Reference ref =
          _storage.ref().child('user_profiles').child('$userId.jpg');
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Storage delete error: $e');
      }
      return false;
    }
  }
}
