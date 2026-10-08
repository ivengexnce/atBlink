import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';
import '../models/review_model.dart';
import '../models/user_profile_model.dart';

class FirestoreService {
  /// Safely access FirebaseFirestore instance, returning null if Firebase isn't initialized yet
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------
  // 1. USER LOGIN & PROFILE FIRESTORE SYNC
  // ---------------------------------------------------------

  /// Saves or updates user login info and session metadata in Firestore
  Future<bool> saveUserLoginInfo(UserProfile user) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return false;

      final docRef = firestore.collection('users').doc(user.id);
      final data = {
        ...user.toMap(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      };

      await docRef.set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Firestore saveUserLoginInfo error (offline/demo): $e');
      }
      return false;
    }
  }

  /// Fetches user profile document from Firestore
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final doc = await firestore.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          return UserProfile.fromMap(doc.data()!);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore fetchUserProfile error: $e');
      }
    }
    return null;
  }

  // ---------------------------------------------------------
  // 2. ORDERS MANAGEMENT IN FIRESTORE
  // ---------------------------------------------------------

  /// Saves an order to Firestore and persists locally as backup
  Future<bool> saveOrder(OrderModel order) async {
    bool firestoreSuccess = false;
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final orderData = {
          ...order.toMap(),
          'serverTimestamp': FieldValue.serverTimestamp(),
        };

        // 1. Global orders collection
        await firestore.collection('orders').doc(order.orderId).set(orderData);

        // 2. User subcollection for fast querying
        if (order.userId.isNotEmpty) {
          await firestore
              .collection('users')
              .doc(order.userId)
              .collection('orders')
              .doc(order.orderId)
              .set(orderData);
        }
        firestoreSuccess = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore saveOrder error (will cache locally): $e');
      }
    }

    // Always cache locally so orders are instantly visible offline
    await _cacheOrderLocally(order);
    return firestoreSuccess;
  }

  /// Fetches orders placed by the user from Firestore (with local cache fallback)
  Future<List<OrderModel>> fetchUserOrders(String userId) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final querySnapshot = await firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final List<OrderModel> remoteOrders = querySnapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();

          // Sort latest first
          remoteOrders.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
          return remoteOrders;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore fetchUserOrders error, falling back to local storage: $e');
      }
    }

    // Fallback: Read local cached orders
    return _getLocalOrders(userId);
  }

  Future<void> _cacheOrderLocally(OrderModel order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'cached_orders_${order.userId}';
      final List<String> current = prefs.getStringList(key) ?? [];
      current.insert(0, order.toJson());
      await prefs.setStringList(key, current);
    } catch (e) {
      if (kDebugMode) {
        print('Local cache order error: $e');
      }
    }
  }

  Future<List<OrderModel>> _getLocalOrders(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'cached_orders_$userId';
      final List<String>? current = prefs.getStringList(key);
      if (current != null) {
        return current.map((str) => OrderModel.fromJson(str)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Local get orders error: $e');
      }
    }
    return [];
  }

  // ---------------------------------------------------------
  // 3. PRODUCT RATINGS & REVIEWS IN FIRESTORE
  // ---------------------------------------------------------

  /// Submits a user review and rating for a product to Firestore
  Future<bool> submitProductReview(ReviewModel review) async {
    bool firestoreSuccess = false;
    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('product_reviews')
            .doc(review.id)
            .set({
          ...review.toMap(),
          'serverTimestamp': FieldValue.serverTimestamp(),
        });
        firestoreSuccess = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore submitProductReview error: $e');
      }
    }

    // Cache review locally for instant feedback
    await _cacheReviewLocally(review);
    return firestoreSuccess;
  }

  /// Fetches all reviews and ratings for a product from Firestore
  Future<List<ReviewModel>> fetchProductReviews(int productId) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final querySnapshot = await firestore
            .collection('product_reviews')
            .where('productId', isEqualTo: productId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final reviews = querySnapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firestore fetchProductReviews error: $e');
      }
    }

    // Fallback: Combine local reviews with verified community mock reviews
    final localReviews = await _getLocalReviews(productId);
    final defaultMock = _getDefaultCommunityReviews(productId);

    return [...localReviews, ...defaultMock];
  }

  Future<void> _cacheReviewLocally(ReviewModel review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'local_reviews_${review.productId}';
      final List<String> current = prefs.getStringList(key) ?? [];
      current.insert(0, review.toJson());
      await prefs.setStringList(key, current);
    } catch (e) {
      if (kDebugMode) {
        print('Local cache review error: $e');
      }
    }
  }

  Future<List<ReviewModel>> _getLocalReviews(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'local_reviews_$productId';
      final List<String>? current = prefs.getStringList(key);
      if (current != null) {
        return current.map((str) => ReviewModel.fromJson(str)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Local get reviews error: $e');
      }
    }
    return [];
  }

  List<ReviewModel> _getDefaultCommunityReviews(int productId) {
    return [
      ReviewModel(
        id: 'rev_comm_1_$productId',
        productId: productId,
        userId: 'comm_user_1',
        userName: 'Aarav Sharma',
        rating: 5.0,
        comment: 'Super fresh and arrived in just 8 minutes! Outstanding packaging.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ReviewModel(
        id: 'rev_comm_2_$productId',
        productId: productId,
        userId: 'comm_user_2',
        userName: 'Priya Patel',
        rating: 4.5,
        comment: 'Great quality, crisp and exactly as described in the app.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
