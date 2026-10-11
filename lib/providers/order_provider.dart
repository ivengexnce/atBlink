import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Place and save an order to Firebase Firestore
  Future<bool> placeOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firestoreService.saveOrder(order);
      _orders.insert(0, order);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to place order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch order history for the current user
  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orders = await _firestoreService.fetchUserOrders(userId);
    } catch (e) {
      _errorMessage = 'Error loading orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an order status locally and in Firestore
  Future<void> updateOrderStatus(String orderId, String userId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
    await _firestoreService.updateOrderStatus(orderId, userId, newStatus);
  }
}
