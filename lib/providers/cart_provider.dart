import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  Timer? _saveDebounceTimer;

  Map<int, CartItem> get items => _items;

  List<CartItem> get cartItemList => _items.values.toList();

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => (subtotal > 199.0 || subtotal == 0) ? 0.0 : 15.0;

  double get handlingFee => subtotal > 0 ? 5.0 : 0.0;

  double get grandTotal => subtotal + deliveryFee + handlingFee;

  CartProvider() {
    _loadCart();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }

  int getProductQuantity(int productId) {
    if (_items.containsKey(productId)) {
      return _items[productId]!.quantity;
    }
    return 0;
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    _scheduleSaveCart();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    _scheduleSaveCart();
    notifyListeners();
  }

  void removeItemCompletely(int productId) {
    _items.remove(productId);
    _scheduleSaveCart();
    notifyListeners();
  }

  void clearCart() {
    _saveDebounceTimer?.cancel();
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  /// Creates an immutable order receipt snapshot before clearing the cart
  OrderModel createOrderSnapshot(String deliveryAddress, [String userId = 'guest']) {
    return OrderModel(
      orderId: OrderModel.generateOrderId(),
      userId: userId,
      items: List<CartItem>.from(cartItemList),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      handlingFee: handlingFee,
      grandTotal: grandTotal,
      deliveryAddress: deliveryAddress,
    );
  }

  /// Debounces rapid successive disk writes to prevent storage race conditions
  void _scheduleSaveCart() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _saveCart();
    });
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> cartJsonList =
          _items.values.map((i) => json.encode(i.toJson())).toList();
      await prefs.setStringList(AppConstants.keyCartItems, cartJsonList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart: $e');
      }
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? cartJsonList =
          prefs.getStringList(AppConstants.keyCartItems);
      if (cartJsonList != null) {
        _items.clear();
        for (var itemStr in cartJsonList) {
          final cartItem = CartItem.fromJson(json.decode(itemStr));
          _items[cartItem.product.id] = cartItem;
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    }
  }
}
