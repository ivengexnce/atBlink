import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../models/review_model.dart';
import '../providers/cart_provider.dart';
import '../providers/profile_provider.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews =
        await _firestoreService.fetchProductReviews(widget.product.id);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return widget.product.rating;
    final total = _reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  void _showRateProductBottomSheet(BuildContext context) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.userProfile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.thumbnail,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'Rate your fresh experience',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isFilled = starValue <= selectedRating;
                        return IconButton(
                          onPressed: () {
                            setModalState(() {
                              selectedRating = starValue;
                            });
                          },
                          icon: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFFB800),
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Share your experience (e.g. Freshness, taste, quality)...',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final comment = commentController.text.trim();
                        final reviewId =
                            'rev_${DateTime.now().millisecondsSinceEpoch}';

                        final newReview = ReviewModel(
                          id: reviewId,
                          productId: widget.product.id,
                          userId: user?.id ?? 'guest',
                          userName: user?.name.isNotEmpty == true
                              ? user!.name
                              : 'Verified Shopper',
                          userPhoto: user?.photoUrl ?? '',
                          rating: selectedRating,
                          comment: comment.isNotEmpty
                              ? comment
                              : 'Great product, loved it!',
                          createdAt: DateTime.now(),
                        );

                        Navigator.pop(ctx);

                        // Submit to Firebase Firestore
                        await _firestoreService
                            .submitProductReview(newReview);

                        setState(() {
                          _reviews.insert(0, newReview);
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('⭐ Review submitted to Firebase!'),
                              backgroundColor: AppColors.primaryGreen,
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Submit Review to Firebase',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final qty = cartProvider.getProductQuantity(widget.product.id);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.brand),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isDesktop
              ? _buildDesktopLayout(cartProvider, qty)
              : _buildMobileLayout(cartProvider, qty),
        ),
      ),
    );
  }

  // Desktop 2-Column Split
  Widget _buildDesktopLayout(CartProvider cartProvider, int qty) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Image & Trust Badges)
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildImageShowcase(height: 380),
                const SizedBox(height: 20),
                _buildWhyAtBlinkFeatures(),
              ],
            ),
          ),
          const SizedBox(width: 36),

          // Right Column (Details, Actions, Reviews)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderDetails(),
                const SizedBox(height: 14),
                _buildPriceSection(),
                const SizedBox(height: 20),
                // Inline Desktop Cart Action Button
                _buildDesktopAddToCartBar(cartProvider, qty),
                const Divider(height: 36),
                _buildDescriptionSection(),
                const Divider(height: 36),
                _buildReviewsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Stacked Layout with Sticky Bottom Bar
  Widget _buildMobileLayout(CartProvider cartProvider, int qty) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageShowcase(height: 260),
                const SizedBox(height: 20),
                _buildHeaderDetails(),
                const SizedBox(height: 14),
                _buildPriceSection(),
                const Divider(height: 32),
                _buildWhyAtBlinkFeatures(),
                const SizedBox(height: 20),
                _buildDescriptionSection(),
                const Divider(height: 32),
                _buildReviewsSection(),
              ],
            ),
          ),
        ),
        // Sticky Bottom Add to Cart Bar for Mobile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TOTAL PRICE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₹${(widget.product.discountedPrice * (qty > 0 ? qty : 1)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: qty == 0
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            cartProvider.addToCart(widget.product);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_shopping_cart_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'ADD TO CART',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  cartProvider.removeFromCart(widget.product.id);
                                },
                              ),
                              Text(
                                '$qty IN CART',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  cartProvider.addToCart(widget.product);
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageShowcase({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'product_img_${widget.product.id}',
              child: Image.network(
                widget.product.thumbnail,
                fit: BoxFit.contain,
                height: height * 0.78,
                cacheWidth: 450,
                cacheHeight: 450,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_rounded,
                  size: 64,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          if (widget.product.discountPercentage > 0)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.discountBadge,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.product.discountPercentage.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 14, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    widget.product.deliveryEta,
                    style: const TextStyle(
                      fontSize: 11,
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
    );
  }

  Widget _buildHeaderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.product.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.star_rounded,
                      color: Colors.white, size: 15),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Unit / Net Weight: ${widget.product.unitQuantity}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Text(
          '₹${widget.product.discountedPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        if (widget.product.discountPercentage > 0)
          Text(
            '₹${widget.product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'IN STOCK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAddToCartBar(CartProvider cartProvider, int qty) {
    return Row(
      children: [
        if (qty == 0)
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => cartProvider.addToCart(widget.product),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text(
                'ADD TO CART',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_rounded, color: Colors.white),
                    onPressed: () =>
                        cartProvider.removeFromCart(widget.product.id),
                  ),
                  Text(
                    '$qty IN CART',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () => cartProvider.addToCart(widget.product),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWhyAtBlinkFeatures() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(Icons.bolt_rounded,
                  color: AppColors.primaryGreen, size: 24),
              SizedBox(height: 4),
              Text('10 Mins ETA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          Column(
            children: [
              Icon(Icons.verified_user_rounded,
                  color: AppColors.primaryGreen, size: 24),
              SizedBox(height: 4),
              Text('Fresh Guarantee',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          Column(
            children: [
              Icon(Icons.published_with_changes_rounded,
                  color: AppColors.primaryGreen, size: 24),
              SizedBox(height: 4),
              Text('Easy Return',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this Product',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_reviews.length} ratings on Firebase',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showRateProductBottomSheet(context),
              icon: const Icon(Icons.rate_review_rounded, size: 16),
              label: const Text('Write Review',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_isLoadingReviews)
          const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
        else if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No reviews yet. Be the first to review this product!',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          )
        else
          ..._reviews.map((r) => _buildReviewCard(r)),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 13,
                            color: const Color(0xFFFFB800),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
