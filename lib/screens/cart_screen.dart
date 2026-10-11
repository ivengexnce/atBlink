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

  static const List<Map<String, dynamic>> _instructionOptions = [
    {'title': 'Leave at door', 'icon': Icons.door_front_door_rounded},
    {'title': 'Don\'t ring bell', 'icon': Icons.notifications_off_rounded},
    {'title': 'Avoid calling', 'icon': Icons.phone_disabled_rounded},
    {'title': 'Leave with guard', 'icon': Icons.shield_rounded},
  ];

  void _onPlaceOrder(
      BuildContext context, CartProvider cartProvider, dynamic userProfile) {
    final deliveryAddress = userProfile?.address ??
        'Flat 402, Green Park Heights, Cyber City';
    final userId = userProfile?.id ?? 'guest';
    final orderSnapshot =
        cartProvider.createOrderSnapshot(deliveryAddress, userId);

    context.read<OrderProvider>().placeOrder(orderSnapshot);
    cartProvider.clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(order: orderSnapshot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final userProfile = context.watch<ProfileProvider>().userProfile;

    final double amountForFreeDelivery =
        (199.0 - cartProvider.subtotal).clamp(0.0, 199.0);
    final double freeDeliveryProgress =
        (cartProvider.subtotal / 199.0).clamp(0.0, 1.0);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final double horizontalPadding =
        screenWidth > 1140 ? (screenWidth - 1100) / 2 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Cart'),
        actions: [
          if (cartProvider.itemCount > 0)
            TextButton.icon(
              onPressed: cartProvider.clearCart,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 18),
              label: const Text(
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
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
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
                        fontSize: 22,
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
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(
                        'Start Shopping',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : isDesktop
              ? _buildDesktopCheckoutLayout(
                  context: context,
                  cartProvider: cartProvider,
                  userProfile: userProfile,
                  amountForFreeDelivery: amountForFreeDelivery,
                  freeDeliveryProgress: freeDeliveryProgress,
                  horizontalPadding: horizontalPadding,
                )
              : _buildMobileCheckoutLayout(
                  context: context,
                  cartProvider: cartProvider,
                  userProfile: userProfile,
                  amountForFreeDelivery: amountForFreeDelivery,
                  freeDeliveryProgress: freeDeliveryProgress,
                ),
    );
  }

  // Desktop Responsive 2-Column Split
  Widget _buildDesktopCheckoutLayout({
    required BuildContext context,
    required CartProvider cartProvider,
    required dynamic userProfile,
    required double amountForFreeDelivery,
    required double freeDeliveryProgress,
    required double horizontalPadding,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Items, Address, Notes)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFreeDeliveryBanner(
                    cartProvider, amountForFreeDelivery, freeDeliveryProgress),
                const SizedBox(height: 16),
                _buildDeliveryAddressCard(userProfile),
                const SizedBox(height: 16),
                _buildCartItemsCard(cartProvider),
                const SizedBox(height: 16),
                _buildInstructionsCard(),
                const SizedBox(height: 16),
                _buildCancellationCard(),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Right Column (Sticky Summary & Checkout Action)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillDetailsCard(cartProvider),
                const SizedBox(height: 16),
                // Place Order Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () =>
                        _onPlaceOrder(context, cartProvider, userProfile),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: AppColors.primaryYellow, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Pay ₹${cartProvider.grandTotal.toStringAsFixed(2)} • Place Order',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Trust Badges
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              size: 16, color: AppColors.primaryGreen),
                          SizedBox(width: 6),
                          Text('100% Secure',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 16, color: AppColors.primaryGreen),
                          SizedBox(width: 6),
                          Text('Instant Refund',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Stacked Layout with Bottom Action Bar
  Widget _buildMobileCheckoutLayout({
    required BuildContext context,
    required CartProvider cartProvider,
    required dynamic userProfile,
    required double amountForFreeDelivery,
    required double freeDeliveryProgress,
  }) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFreeDeliveryBanner(
                    cartProvider, amountForFreeDelivery, freeDeliveryProgress),
                const SizedBox(height: 14),
                _buildDeliveryAddressCard(userProfile),
                const SizedBox(height: 14),
                _buildCartItemsCard(cartProvider),
                const SizedBox(height: 14),
                _buildInstructionsCard(),
                const SizedBox(height: 14),
                _buildBillDetailsCard(cartProvider),
                const SizedBox(height: 14),
                _buildCancellationCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Bottom Sticky Checkout Button
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
              onPressed: () =>
                  _onPlaceOrder(context, cartProvider, userProfile),
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
    );
  }

  Widget _buildFreeDeliveryBanner(CartProvider cartProvider,
      double amountForFreeDelivery, double freeDeliveryProgress) {
    final hasFree = cartProvider.subtotal >= 199.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasFree ? AppColors.lightGreen : const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFree ? AppColors.primaryGreen : AppColors.primaryYellow,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFree ? Icons.verified_rounded : Icons.electric_bolt_rounded,
                color: hasFree ? AppColors.primaryGreen : const Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasFree
                      ? '🎉 Free delivery unlocked on this order!'
                      : 'Add ₹${amountForFreeDelivery.toStringAsFixed(0)} more for FREE Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: hasFree
                        ? AppColors.primaryGreen
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          if (!hasFree) ...[
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
    );
  }

  Widget _buildDeliveryAddressCard(dynamic userProfile) {
    return Container(
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
    );
  }

  Widget _buildCartItemsCard(CartProvider cartProvider) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final cartItem = cartProvider.cartItemList[index];
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
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.image_not_supported_rounded,
                          size: 24,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            cartProvider.removeFromCart(product.id);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.remove_rounded,
                                size: 14, color: Colors.white),
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
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.add_rounded,
                                size: 14, color: Colors.white),
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
    );
  }

  Widget _buildInstructionsCard() {
    return Column(
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
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _instructionOptions.length,
            itemBuilder: (context, i) {
              final isSel = _selectedInstruction == i;
              final item = _instructionOptions[i];

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedInstruction = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.lightGreen : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSel ? AppColors.primaryGreen : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData,
                            size: 15,
                            color: isSel
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSel ? FontWeight.w800 : FontWeight.w600,
                            color: isSel
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBillDetailsCard(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 18, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Bill Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildBillRow('Item Total',
              '₹${cartProvider.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildBillRow(
            'Delivery Fee',
            cartProvider.deliveryFee == 0
                ? 'FREE'
                : '₹${cartProvider.deliveryFee.toStringAsFixed(2)}',
            isFree: cartProvider.deliveryFee == 0,
          ),
          const SizedBox(height: 10),
          _buildBillRow(
            'Handling Fee',
            cartProvider.handlingFee == 0
                ? 'FREE'
                : '₹${cartProvider.handlingFee.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }

  Widget _buildCancellationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, size: 18, color: AppColors.textMuted),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Orders can be cancelled before rider assignment. Once dispatched from the dark store, cancellation may not be possible.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isFree ? FontWeight.w800 : FontWeight.w700,
            fontSize: 13,
            color: isFree ? AppColors.primaryGreen : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
