import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/profile_provider.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import 'admin_product_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final double horizontalPadding = screenWidth > 1240 ? (screenWidth - 1240) / 2 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primaryGreen,
              backgroundColor: Colors.white,
              onRefresh: productProvider.loadProducts,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Responsive Top Navigation Bar
                  SliverToBoxAdapter(
                    child: isDesktop
                        ? _buildDesktopNavBar(
                            context: context,
                            profileProvider: profileProvider,
                            productProvider: productProvider,
                            cartProvider: cartProvider,
                          )
                        : _buildMobileHeader(
                            context: context,
                            profileProvider: profileProvider,
                          ),
                  ),

                  // Promo Banners Section (Adaptive Row on Desktop, Carousel on Mobile)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 14,
                      ),
                      child: isDesktop
                          ? Row(
                              children: [
                                Expanded(
                                  child: _buildPromoCard(
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
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildPromoCard(
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
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildPromoCard(
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
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 125,
                              child: PageView(
                                controller: PageController(viewportFraction: 0.90),
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
                  ),

                  // Categories Shelf Section
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.grid_view_rounded,
                                      color: AppColors.primaryGreen, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Explore Categories',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.primaryGreen
                                          .withValues(alpha: 0.25)),
                                ),
                                child: Text(
                                  '${productProvider.selectedCategory} (${productProvider.products.length})',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: productProvider.categories.length,
                              itemBuilder: (context, index) {
                                final cat = productProvider.categories[index];
                                final isSelected =
                                    productProvider.selectedCategory == cat.name;

                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      productProvider.selectCategory(cat.name);
                                    },
                                    child: Container(
                                      width: 82,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 200),
                                            curve: Curves.easeOutCubic,
                                            height: 62,
                                            width: 62,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryYellow
                                                  : cat.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.textPrimary
                                                    : Colors.white,
                                                width: isSelected ? 2.5 : 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isSelected
                                                      ? AppColors.primaryYellow
                                                          .withValues(alpha: 0.45)
                                                      : Colors.black
                                                          .withValues(alpha: 0.04),
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              height: 1.15,
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
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${productProvider.selectedCategory} Products',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${productProvider.products.length} fresh items delivered in 10 mins',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (productProvider.selectedCategory != 'All')
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  productProvider.resetCategory();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.clear_rounded,
                                          size: 14,
                                          color: AppColors.textSecondary),
                                      SizedBox(width: 4),
                                      Text(
                                        'View All',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Responsive Products Grid or Empty State
                  if (productProvider.isLoading &&
                      productProvider.products.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryGreen)),
                    )
                  else if (productProvider.products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: const BoxDecoration(
                                  color: AppColors.lightGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  size: 48,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                productProvider.selectedCategory == 'All'
                                    ? 'No Products Available'
                                    : 'No Products in ${productProvider.selectedCategory}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                productProvider.selectedCategory == 'All'
                                    ? 'Items are being restocked. Pull down or tap below to refresh.'
                                    : 'We could not find items under "${productProvider.selectedCategory}".',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  if (productProvider.selectedCategory != 'All') {
                                    productProvider.resetCategory();
                                  } else {
                                    productProvider.loadProducts();
                                  }
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: Text(
                                  productProvider.selectedCategory != 'All'
                                      ? 'Show All Categories'
                                      : 'Refresh Store',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Builder(
                      builder: (context) {
                        final textScale =
                            MediaQuery.of(context).textScaler.scale(1.0);

                        // Responsive Grid Cross Axis Count & Aspect Ratio
                        final int crossAxisCount;
                        final double childAspectRatio;

                        if (screenWidth >= 1200) {
                          crossAxisCount = 5;
                          childAspectRatio = 0.74;
                        } else if (screenWidth >= 900) {
                          crossAxisCount = 4;
                          childAspectRatio = 0.72;
                        } else if (screenWidth >= 600) {
                          crossAxisCount = 3;
                          childAspectRatio = 0.70;
                        } else {
                          crossAxisCount = 2;
                          if (screenWidth < 370 || textScale > 1.05) {
                            childAspectRatio = 0.58;
                          } else if (screenWidth < 400) {
                            childAspectRatio = 0.60;
                          } else {
                            childAspectRatio = 0.63;
                          }
                        }

                        return SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 8,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            sliver: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = productProvider.products[index];
                                return _ProductCard(
                                  product: product,
                                  cartProvider: cartProvider,
                                );
                              },
                              childCount: productProvider.products.length,
                            ),
                          ),
                        );
                      },
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ),
            ),

            // Responsive Floating Bottom Cart Bar
            if (cartProvider.itemCount > 0)
              Positioned(
                left: screenWidth > 640 ? (screenWidth - 600) / 2 : 16,
                right: screenWidth > 640 ? (screenWidth - 600) / 2 : 16,
                bottom: 16,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.cartGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.4),
                          blurRadius: 18,
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
                            const SizedBox(width: 14),
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
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CartScreen()),
                            );
                          },
                          child: const Row(
                            children: [
                              Text(
                                'View Cart',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14),
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
              ),
          ],
        ),
      ),
    );
  }

  // Desktop Web Top Navigation Bar
  Widget _buildDesktopNavBar({
    required BuildContext context,
    required ProfileProvider profileProvider,
    required ProductProvider productProvider,
    required CartProvider cartProvider,
  }) {
    final userProfile = profileProvider.userProfile;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.yellowGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Logo & Brand
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'atBlink',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: AppColors.primaryYellow, size: 14),
                          SizedBox(width: 2),
                          Text(
                            '10 MINS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Location selector pill
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () =>
                        _showAddressSelector(context, profileProvider),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.primaryGreen, size: 16),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              userProfile?.address ?? 'Select Address',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Expanded Search Bar
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                      },
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search_rounded,
                                color: AppColors.primaryGreen, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search groceries, dairy, snacks, farm fresh veggies...',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.tune_rounded,
                                color: AppColors.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Navigation Item: Orders
                _buildDesktopNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Navigation Item: Admin
                _buildDesktopNavItem(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Admin',
                  badge: 'HUB',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminProductScreen()),
                    );
                  },
                ),
                const SizedBox(width: 12),

                // Desktop Cart Action Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: Text(
                      cartProvider.itemCount > 0
                          ? '${cartProvider.itemCount} | ₹${cartProvider.grandTotal.toStringAsFixed(0)}'
                          : 'My Cart',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Profile Avatar Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (userProfile?.photoUrl.isNotEmpty == true)
                              ? NetworkImage(userProfile!.photoUrl)
                              : null,
                      child: (userProfile?.photoUrl.isEmpty ?? true)
                          ? const Icon(Icons.person_rounded,
                              color: AppColors.primaryGreen, size: 22)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile Top Header with Delivery Info & Search
  Widget _buildMobileHeader({
    required BuildContext context,
    required ProfileProvider profileProvider,
  }) {
    final userProfile = profileProvider.userProfile;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                              Icon(Icons.bolt_rounded,
                                  color: AppColors.primaryYellow, size: 15),
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
                    InkWell(
                      onTap: () =>
                          _showAddressSelector(context, profileProvider),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.primaryGreen, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                userProfile?.address ??
                                    'Select Delivery Address',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.black54, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
                        ? const Icon(Icons.person_rounded,
                            color: AppColors.primaryGreen, size: 24)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8)),
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
                  Icon(Icons.tune_rounded,
                      color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
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
            Icon(icon, size: 52, color: Colors.white.withValues(alpha: 0.88)),
          ],
        ),
      ),
    );
  }

  void _showAddressSelector(
      BuildContext context, ProfileProvider profileProvider) {
    final currentAddress = profileProvider.userProfile?.address ?? '';
    const defaultAddresses = [
      {
        'tag': 'Home',
        'address':
            'Flat 402, Sunshine Heights, Koramangala 4th Block, Bengaluru',
        'icon': Icons.home_rounded,
      },
      {
        'tag': 'Work',
        'address':
            'WeWork Galaxy, 43 Residency Rd, Shanthala Nagar, Bengaluru',
        'icon': Icons.business_rounded,
      },
      {
        'tag': 'Other',
        'address': '12th Main Road, Indiranagar, Bengaluru - 560038',
        'icon': Icons.location_on_rounded,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.location_searching_rounded,
                      color: AppColors.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Select Delivery Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Orders arrive lightning-fast in 10-15 minutes',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Detecting real-time device location...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  final result =
                      await LocationService().getCurrentDeviceAddress();
                  if (result.success) {
                    await profileProvider
                        .updateDeliveryAddress('GPS: ${result.address}');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('📍 Location updated: ${result.address}'),
                          backgroundColor: AppColors.primaryGreen,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.errorMessage ??
                            'Unable to detect GPS. Using nearest hub.'),
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryGreen,
                        child: Icon(Icons.my_location_rounded,
                            color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Current Location',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Auto-detect using device GPS & sensors',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR CHOOSE SAVED ADDRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              ...defaultAddresses.map((item) {
                final tag = item['tag'] as String;
                final addr = item['address'] as String;
                final icon = item['icon'] as IconData;
                final isSelected =
                    currentAddress.contains(tag) || currentAddress == addr;

                return InkWell(
                  onTap: () {
                    profileProvider.updateDeliveryAddress('$tag: $addr');
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Delivery address set to $tag'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightGreen
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tag,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                addr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Dynamic Product Card with Hover Elevation on Desktop Web
class _ProductCard extends StatefulWidget {
  final Product product;
  final CartProvider cartProvider;

  const _ProductCard({
    required this.product,
    required this.cartProvider,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = widget.cartProvider;
    final qty = cartProvider.getProductQuantity(product.id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product)),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primaryGreen.withValues(alpha: 0.5)
                  : AppColors.border,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primaryGreen.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 14 : 8,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Showcase
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFF9FAFB),
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.contain,
                          cacheWidth: 350,
                          cacheHeight: 350,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 36,
                              color: AppColors.textMuted,
                            ),
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
                                color: AppColors.discountBadge
                                    .withValues(alpha: 0.3),
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
                              fontWeight: FontWeight.w800,
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
                            const Icon(Icons.bolt_rounded,
                                size: 12, color: AppColors.primaryGreen),
                            const SizedBox(width: 2),
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

              // Details
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.unitQuantity,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
                                fontSize: 15,
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
                            height: 33,
                            width: 68,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: AppColors.lightGreen,
                                side: const BorderSide(
                                    color: AppColors.primaryGreen, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                cartProvider.addToCart(product);
                              },
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 33,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    cartProvider.removeFromCart(product.id);
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 7),
                                    child: Icon(Icons.remove_rounded,
                                        size: 15, color: Colors.white),
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    cartProvider.addToCart(product);
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 7),
                                    child: Icon(Icons.add_rounded,
                                        size: 15, color: Colors.white),
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
      ),
    );
  }
}
