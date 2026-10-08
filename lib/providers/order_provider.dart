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
    notifyListeners();

    try {
      await _firestoreService.saveOrder(order);
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to place order: $e';
      notifyListeners();
      return false;
    }
  }

  /// Fetch order history for the current user
  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.fetchUserOrders(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading orders: $e';
      notifyListeners();
    }
  }
}
