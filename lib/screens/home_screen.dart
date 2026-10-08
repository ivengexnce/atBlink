import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/constants.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    final userProfile = profileProvider.userProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header Sliver with Gradient
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.yellowGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location & Profile Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bolt_rounded,
                                              color: AppColors.primaryYellow,
                                              size: 15,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              '10 MINS',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'DELIVERY TO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.primaryGreen,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          userProfile?.address ?? 'Select Delivery Address',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Profile Avatar
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  backgroundImage: (userProfile?.photoUrl != null &&
                                          userProfile!.photoUrl.isNotEmpty)
                                      ? NetworkImage(userProfile.photoUrl)
                                      : null,
                                  child: (userProfile?.photoUrl == null ||
                                          userProfile!.photoUrl.isEmpty)
                                      ? const Icon(
                                          Icons.person_rounded,
                                          color: AppColors.primaryGreen,
                                          size: 24,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Search Bar Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search_rounded,
                                    color: AppColors.primaryGreen, size: 22),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Search "milk", "fresh apples", "chips"...',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.mic_none_rounded,
                                    color: AppColors.textSecondary, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Promo Banner Carousel
                SliverToBoxAdapter(
                  child: Container(
                    height: 125,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    child: PageView(
                      controller: PageController(viewportFraction: 0.88),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPromoCard(
                          title: 'Farm Fresh Harvest',
                          subtitle: 'Up to 40% OFF Green Vegetables & Fruits',
                          badge: 'FLASH SALE',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          icon: Icons.eco_rounded,
                        ),
                        _buildPromoCard(
                          title: 'Instant Munchies',
                          subtitle: 'Crisps, Cold Drinks & Chocolates in 8 mins!',
                          badge: 'EXPRESS',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          icon: Icons.bolt_rounded,
                        ),
                        _buildPromoCard(
                          title: 'Morning Essentials',
                          subtitle: 'Farm fresh dairy & bread delivered daily',
                          badge: 'SUPER SAVER',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFEF6C00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          icon: Icons.free_breakfast_rounded,
                        ),
                      ],
                    ),
                  ),
                ),

                // Categories Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Explore Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${productProvider.categories.length} Types',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: productProvider.categories.length,
                            itemBuilder: (context, index) {
                              final cat = productProvider.categories[index];
                              final isSelected =
                                  productProvider.selectedCategory == cat.name;

                              return GestureDetector(
                                onTap: () {
                                  productProvider.selectCategory(cat.name);
                                },
                                child: Container(
                                  width: 78,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: 62,
                                        width: 62,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryYellow
                                              : cat.backgroundColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.textPrimary
                                                : Colors.white,
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected
                                                  ? AppColors.primaryYellow.withValues(alpha: 0.4)
                                                  : Colors.black.withValues(alpha: 0.04),
                                              blurRadius: isSelected ? 8 : 4,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          cat.iconData,
                                          color: isSelected
                                              ? Colors.black
                                              : AppColors.primaryGreen,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product Grid Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${productProvider.selectedCategory} Products',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (productProvider.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Products Grid
                if (productProvider.isLoading &&
                    productProvider.products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    ),
                  )
                else if (productProvider.products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No products available in this category.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = productProvider.products[index];
                          return _buildProductCard(context, product, cartProvider);
                        },
                        childCount: productProvider.products.length,
                      ),
                    ),
                  ),

                // Bottom padding space for floating cart bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 110),
                ),
              ],
            ),

            // Floating Bottom Cart Bar with Visual Progress Hint
            if (cartProvider.itemCount > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppColors.cartGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? "ITEM" : "ITEMS"}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '₹${cartProvider.grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Text(
                              'View Cart',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required String badge,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 54, color: Colors.white.withValues(alpha: 0.85)),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, CartProvider cartProvider) {
    final qty = cartProvider.getProductQuantity(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF9FAFB),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.discountBadge,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.discountBadge.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '${product.discountPercentage.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 11, color: AppColors.primaryGreen),
                          const SizedBox(width: 3),
                          Text(
                            product.deliveryEta,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Details
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.unitQuantity,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${product.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (product.discountPercentage > 0)
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),

                      // ADD / Stepper Button
                      if (qty == 0)
                        SizedBox(
                          height: 34,
                          width: 68,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: AppColors.lightGreen,
                              side: const BorderSide(
                                  color: AppColors.primaryGreen, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              cartProvider.addToCart(product);
                            },
                            child: const Text(
                              'ADD',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  cartProvider.removeFromCart(product.id);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Icon(Icons.remove,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  cartProvider.addToCart(product);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Icon(Icons.add,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
