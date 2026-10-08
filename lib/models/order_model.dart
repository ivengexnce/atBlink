import 'dart:convert';
import 'cart_item_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double handlingFee;
  final double grandTotal;
  final String deliveryAddress;
  final String status;
  final DateTime orderedAt;

  OrderModel({
    required this.orderId,
    this.userId = 'guest',
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.handlingFee,
    required this.grandTotal,
    required this.deliveryAddress,
    this.status = 'Out for Delivery (10 Mins)',
    DateTime? orderedAt,
  }) : orderedAt = orderedAt ?? DateTime.now();

  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ATB-${timestamp.toRadixString(36).toUpperCase()}';
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((x) => x.toJson()).toList(),
      'itemCount': items.fold<int>(0, (sum, i) => sum + i.quantity),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'handlingFee': handlingFee,
      'grandTotal': grandTotal,
      'deliveryAddress': deliveryAddress,
      'status': status,
      'orderedAt': orderedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return OrderModel(
      orderId: docId ?? map['orderId']?.toString() ?? generateOrderId(),
      userId: map['userId']?.toString() ?? 'guest',
      items: map['items'] != null
          ? (map['items'] as List<dynamic>)
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      handlingFee: (map['handlingFee'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: map['deliveryAddress']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Delivered',
      orderedAt: map['orderedAt'] != null
          ? DateTime.tryParse(map['orderedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source));
}
