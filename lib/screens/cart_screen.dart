import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/constants.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedInstruction = 0;
  final List<String> _instructions = [
    'Leave at door',
    'Don\'t ring bell',
    'Avoid calling',
    'Leave with guard',
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final userProfile = profileProvider.userProfile;

    final double amountForFreeDelivery = (199.0 - cartProvider.subtotal).clamp(0.0, 199.0);
    final double freeDeliveryProgress = (cartProvider.subtotal / 199.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Cart'),
        actions: [
          if (cartProvider.itemCount > 0)
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: cartProvider.cartItemList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 72,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add groceries & essentials delivered to your doorstep in 10 minutes!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Free Delivery Milestone Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cartProvider.subtotal >= 199.0
                                ? AppColors.lightGreen
                                : const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cartProvider.subtotal >= 199.0
                                  ? AppColors.primaryGreen
                                  : AppColors.primaryYellow,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    cartProvider.subtotal >= 199.0
                                        ? Icons.verified_rounded
                                        : Icons.electric_bolt_rounded,
                                    color: cartProvider.subtotal >= 199.0
                                        ? AppColors.primaryGreen
                                        : const Color(0xFFD97706),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      cartProvider.subtotal >= 199.0
                                          ? '🎉 Free delivery unlocked on this order!'
                                          : 'Add ₹${amountForFreeDelivery.toStringAsFixed(0)} more for FREE Delivery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: cartProvider.subtotal >= 199.0
                                            ? AppColors.primaryGreen
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (cartProvider.subtotal < 199.0) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: freeDeliveryProgress,
                                    minHeight: 6,
                                    backgroundColor: Colors.white,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Delivery Address Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Express 10-Minute Delivery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryGreen,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      userProfile?.address ??
                                          'Flat 402, Green Park Heights, Cyber City',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Cart Items Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Review Items (${cartProvider.itemCount})',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    '₹${AppConstants.currencySymbol}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 22),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cartProvider.cartItemList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 20),
                                itemBuilder: (context, index) {
                                  final cartItem =
                                      cartProvider.cartItemList[index];
                                  final product = cartItem.product;

                                  return Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          color: const Color(0xFFF9FAFB),
                                          child: Image.network(
                                            product.thumbnail,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 24,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13.5,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${product.unitQuantity} • ₹${product.discountedPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Compact Stepper
                                      Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                cartProvider.removeFromCart(
                                                    product.id);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Icon(Icons.remove,
                                                    size: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                cartProvider.addToCart(product);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Icon(Icons.add,
                                                    size: 14,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Delivery Instructions Row
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Instructions',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 36,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _instructions.length,
                                itemBuilder: (context, i) {
                                  final isSel = _selectedInstruction == i;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedInstruction = i;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? AppColors.lightGreen
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSel
                                              ? AppColors.primaryGreen
                                              : AppColors.border,
                                        ),
                                      ),
                                      child: Text(
                                        _instructions[i],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSel
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSel
                                              ? AppColors.primaryGreen
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Bill Breakdown Receipt Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bill Details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Items Subtotal',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                  Text(
                                    '₹${cartProvider.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Text('Delivery Partner Fee',
                                          style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13)),
                                    ],
                                  ),
                                  Text(
                                    cartProvider.deliveryFee == 0
                                        ? 'FREE'
                                        : '₹${cartProvider.deliveryFee.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: cartProvider.deliveryFee == 0
                                          ? AppColors.primaryGreen
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Handling & Bag Fee',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                  Text(
                                    '₹${cartProvider.handlingFee.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              const Divider(height: 22),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Grand Total',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '₹${cartProvider.grandTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Checkout Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final deliveryAddress = userProfile?.address ??
                            'Flat 402, Green Park Heights, Cyber City';
                        final userId = userProfile?.id ?? 'guest';
                        final orderSnapshot =
                            cartProvider.createOrderSnapshot(deliveryAddress, userId);

                        // Persist to Firebase Firestore & local state
                        context.read<OrderProvider>().placeOrder(orderSnapshot);

                        cartProvider.clearCart();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderSuccessScreen(order: orderSnapshot),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: AppColors.primaryYellow, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Pay ₹${cartProvider.grandTotal.toStringAsFixed(2)} • 10 Mins Delivery',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
