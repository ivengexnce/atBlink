import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Active timers for auto-updating orders
  final Map<String, Timer> _autoUpdateTimers = {};

  static const List<String> deliveryStages = [
    'Order Confirmed',
    'Items Picked & Packed',
    'Rider Assigned',
    'Out for Express Delivery',
    'Delivered',
  ];

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if a specific order is currently auto-updating
  bool isAutoUpdating(String orderId) => _autoUpdateTimers.containsKey(orderId);

  /// Map string status to 0..4 stage index
  int getStageIndex(String status) {
    if (status.contains('Delivered')) return 4;
    if (status.contains('Out for Express') || status.contains('Out for Delivery')) return 3;
    if (status.contains('Rider Assigned')) return 2;
    if (status.contains('Packed') || status.contains('Picked')) return 1;
    return 0; // Order Confirmed / default
  }

  /// Start auto-progression simulation for an active order
  void startAutoProgress(
    String orderId,
    String userId, {
    Duration interval = const Duration(seconds: 8),
  }) {
    _autoUpdateTimers[orderId]?.cancel();

    _autoUpdateTimers[orderId] = Timer.periodic(interval, (timer) async {
      final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex == -1) {
        timer.cancel();
        _autoUpdateTimers.remove(orderId);
        notifyListeners();
        return;
      }

      final currentStatus = _orders[orderIndex].status;
      final currentIndex = getStageIndex(currentStatus);

      if (currentIndex < deliveryStages.length - 1) {
        final nextStatus = deliveryStages[currentIndex + 1];
        await updateOrderStatus(orderId, userId, nextStatus);

        if (nextStatus == 'Delivered') {
          timer.cancel();
          _autoUpdateTimers.remove(orderId);
          notifyListeners();
        }
      } else {
        timer.cancel();
        _autoUpdateTimers.remove(orderId);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Stop auto-progression for an order
  void stopAutoProgress(String orderId) {
    _autoUpdateTimers[orderId]?.cancel();
    _autoUpdateTimers.remove(orderId);
    notifyListeners();
  }

  /// Manually advance order stage immediately
  Future<void> advanceOrderStage(String orderId, String userId) async {
    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) return;

    final currentStatus = _orders[orderIndex].status;
    final currentIndex = getStageIndex(currentStatus);
    final nextIndex = (currentIndex + 1) % deliveryStages.length;
    await updateOrderStatus(orderId, userId, deliveryStages[nextIndex]);
  }

  /// Place and save an order to Firebase Firestore and start auto-updating
  Future<bool> placeOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firestoreService.saveOrder(order);
      _orders.insert(0, order);

      // Automatically begin auto-updating the order through express stages
      if (!order.status.contains('Delivered')) {
        startAutoProgress(order.orderId, order.userId);
      }
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

      // Auto-progress any in-flight active orders
      for (final order in _orders) {
        if (!order.status.contains('Delivered') && !_autoUpdateTimers.containsKey(order.orderId)) {
          startAutoProgress(order.orderId, userId);
        }
      }
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

  @override
  void dispose() {
    for (final timer in _autoUpdateTimers.values) {
      timer.cancel();
    }
    _autoUpdateTimers.clear();
    super.dispose();
  }
}
