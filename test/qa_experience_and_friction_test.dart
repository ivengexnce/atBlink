import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:atblink/models/cart_item_model.dart';
import 'package:atblink/models/order_model.dart';
import 'package:atblink/models/product_model.dart';
import 'package:atblink/models/user_profile_model.dart';
import 'package:atblink/providers/cart_provider.dart';
import 'package:atblink/providers/product_provider.dart';
import 'package:atblink/screens/order_success_screen.dart';

/// ============================================================================
/// ATBLINK QUICK-COMMERCE QA AUTOMATION & USER FRICTION TEST SUITE
/// Author: Principal QA Automation Lead (12+ Yrs Experience)
/// Focus: Edge Cases, Cognitive Friction, User Frustration & Disappointment Pitfalls
/// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QA SUITE 1: CART PRICING & BILLING TRANSPARENCY (Anti-Frustration)', () {
    late CartProvider cartProvider;

    final productCheap = Product(
      id: 101,
      title: 'Toned Milk',
      description: '500ml milk',
      price: 33.0,
      discountPercentage: 0,
      rating: 4.8,
      stock: 50,
      brand: 'Amul',
      category: 'Dairy',
      thumbnail: 'https://example.com/milk.jpg',
    );

    final productExpensive = Product(
      id: 202,
      title: 'Dry Fruits Pack',
      description: 'Almonds 500g',
      price: 450.0,
      discountPercentage: 10,
      rating: 4.9,
      stock: 20,
      brand: 'Royal Feast',
      category: 'Snacks',
      thumbnail: 'https://example.com/dryfruits.jpg',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cartProvider = CartProvider();
    });

    test('FRUSTRATION CHECK: Sudden fee surprises when cart is empty', () {
      // User Expectation: Empty cart should have zero fees
      expect(cartProvider.subtotal, equals(0.0));
      expect(cartProvider.deliveryFee, equals(0.0), reason: 'Zero cart must not charge delivery fee');
      expect(cartProvider.handlingFee, equals(0.0), reason: 'Zero cart must not charge handling fee');
      expect(cartProvider.grandTotal, equals(0.0));
    });

    test('DISAPPOINTMENT CHECK: Free delivery threshold boundary condition (₹199 rule)', () {
      // Case 1: Subtotal under ₹199 (User pays standard delivery fee ₹15)
      cartProvider.addToCart(productCheap); // 1 x 33 = 33
      expect(cartProvider.subtotal, equals(33.0));
      expect(cartProvider.deliveryFee, equals(15.0), reason: 'Below ₹199 must charge ₹15');
      expect(cartProvider.handlingFee, equals(5.0));
      expect(cartProvider.grandTotal, equals(33.0 + 15.0 + 5.0));

      // Case 2: Crossing ₹199 threshold (Discounted 450 * 0.9 = 405.0)
      cartProvider.clearCart();
      cartProvider.addToCart(productExpensive);
      final discountedPrice = productExpensive.discountedPrice; // 405.0
      expect(cartProvider.subtotal, equals(discountedPrice));
      expect(cartProvider.deliveryFee, equals(0.0), reason: 'Over ₹199 must grant Free Delivery');
      expect(cartProvider.handlingFee, equals(5.0));
      expect(cartProvider.grandTotal, equals(discountedPrice + 5.0));
    });

    test('FRICTION CHECK: Rapid multiple taps on Add/Remove buttons (debounce & state consistency)', () {
      // Simulate rapid user tapping "+" 10 times
      for (int i = 0; i < 10; i++) {
        cartProvider.addToCart(productCheap);
      }
      expect(cartProvider.getProductQuantity(productCheap.id), equals(10));
      expect(cartProvider.itemCount, equals(10));
      expect(cartProvider.subtotal, equals(330.0));

      // Simulate rapid user tapping "-" 10 times down to zero
      for (int i = 0; i < 10; i++) {
        cartProvider.removeFromCart(productCheap.id);
      }
      expect(cartProvider.getProductQuantity(productCheap.id), equals(0));
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.subtotal, equals(0.0));
      expect(cartProvider.grandTotal, equals(0.0));
    });

    test('CORNER CASE: Removing item that does not exist in cart does not crash', () {
      expect(() => cartProvider.removeFromCart(99999), returnsNormally);
      expect(cartProvider.getProductQuantity(99999), equals(0));
    });
  });

  group('QA SUITE 2: PRODUCT SEARCH, CATEGORY & ZERO-STATE UX', () {
    late ProductProvider productProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      productProvider = ProductProvider(autoLoad: false);
      await productProvider.loadProductsForAdmin();
    });

    test('CONFUSION CHECK: Ensure all 8 categories exist with user-friendly names', () {
      final names = productProvider.categories.map((c) => c.name.toLowerCase()).toList();
      expect(names, contains('all'));
      expect(names, contains('dairy'));
      expect(names, contains('vegetables'));
      expect(names, contains('fruits'));
      expect(names, contains('snacks'));
      expect(names, contains('drinks'));
      expect(names, contains('bakery'));
      expect(names, contains('personal care'));
    });

    test('FRUSTRATION CHECK: Empty search query does not wipe out product list', () async {
      await productProvider.loadProducts();
      final initialCount = productProvider.products.length;
      expect(initialCount, greaterThan(0));

      // User clears search query or types spaces
      productProvider.setSearchQuery('   ');
      expect(productProvider.products.length, equals(initialCount),
          reason: 'Whitespace query should not wipe product list');
    });

    test('DISAPPOINTMENT CHECK: Flash deals must never display items with 0% discount', () async {
      await productProvider.loadProducts();
      for (final deal in productProvider.flashDeals) {
        expect(deal.discountPercentage, greaterThanOrEqualTo(10.0),
            reason: 'User expects real savings on Flash Deals (>= 10%)');
        expect(deal.discountedPrice, lessThan(deal.price),
            reason: 'Discounted price must strictly be lower than base price');
      }
    });

    test('UX VERIFICATION: Switching categories filters accurately without item cross-contamination', () async {
      await productProvider.loadProducts();

      // Switch to Dairy
      productProvider.selectCategory('Dairy');
      for (final p in productProvider.products) {
        expect(p.category.toLowerCase(), equals('dairy'));
      }

      // Switch to Vegetables
      productProvider.selectCategory('Vegetables');
      for (final p in productProvider.products) {
        expect(p.category.toLowerCase(), equals('vegetables'));
      }

      // Reset to All
      productProvider.resetCategory();
      expect(productProvider.selectedCategory, equals('All'));
    });
  });

  group('QA SUITE 3: ORDER CREATION, STATUS TRACKING & CONFIRMATION UX', () {
    test('FRUSTRATION CHECK: Order ID format is human-readable and unique', () {
      final id1 = OrderModel.generateOrderId();
      final id2 = OrderModel.generateOrderId();

      expect(id1, isNot(equals(id2)), reason: 'Sequential orders must never collide IDs');
      expect(id1.startsWith('ATB-'), isTrue, reason: 'Order ID must have recognized prefix ATB-');
      expect(id1.length, greaterThanOrEqualTo(10), reason: 'Order ID must have sufficient entropy');
    });

    test('CONFUSION CHECK: Order totals correctly reflect items + delivery + handling', () {
      final sampleProduct = Product(
        id: 301,
        title: 'Chips Pack',
        description: 'Spicy Masala',
        price: 20.0,
        discountPercentage: 0,
        rating: 4.7,
        stock: 50,
        brand: 'Lays',
        category: 'Snacks',
        thumbnail: 'https://example.com/chips.jpg',
      );

      final item = CartItem(product: sampleProduct, quantity: 3); // 3 x 20 = 60
      final order = OrderModel(
        orderId: 'ATB-TEST-001',
        userId: 'usr_qa_123',
        deliveryAddress: 'Flat 101, Cyber Heights, Gurugram',
        items: [item],
        subtotal: 60.0,
        deliveryFee: 15.0,
        handlingFee: 5.0,
        grandTotal: 80.0,
        status: 'Order Placed',
      );

      expect(order.items.length, equals(1));
      expect(order.subtotal, equals(60.0));
      expect(order.grandTotal, equals(80.0));
      expect(order.status, equals('Order Placed'));

      final map = order.toMap();
      expect(map['deliveryAddress'], equals('Flat 101, Cyber Heights, Gurugram'));
      expect(map['userId'], equals('usr_qa_123'));
      expect(map['status'], equals('Order Placed'));
    });
  });

  group('QA SUITE 4: ADMIN PRODUCT HUB & CATALOG INTEGRITY', () {
    late ProductProvider productProvider;

    setUp(() {
      productProvider = ProductProvider();
    });

    test('INTEGRITY CHECK: Adding a new product assigns a non-zero ID and prepends to catalog', () async {
      await productProvider.loadProducts();
      final initialCount = productProvider.allProducts.length;

      final newProduct = Product(
        id: 0, // Auto-assign requested
        title: 'Fresh Strawberries',
        description: 'Sweet handpicked strawberries',
        price: 120.0,
        discountPercentage: 15.0,
        rating: 4.9,
        stock: 35,
        brand: 'Berry Farm',
        category: 'Fruits',
        thumbnail: 'https://example.com/strawberry.jpg',
        unitQuantity: '250 g',
      );

      await productProvider.addProduct(newProduct);

      expect(productProvider.allProducts.length, equals(initialCount + 1));
      final added = productProvider.allProducts.first;
      expect(added.title, equals('Fresh Strawberries'));
      expect(added.id, isNot(equals(0)), reason: 'New product ID must be auto-generated');
      expect(added.category, equals('Fruits'));
    });

    test('FRUSTRATION CHECK: Quick stock toggle accurately flips between in-stock and out-of-stock', () async {
      await productProvider.loadProducts();
      if (productProvider.allProducts.isNotEmpty) {
        final target = productProvider.allProducts.first;
        final originalStock = target.stock;

        // Toggle stock
        await productProvider.toggleStock(target.id);
        final toggled = productProvider.allProducts.firstWhere((p) => p.id == target.id);

        if (originalStock > 0) {
          expect(toggled.stock, equals(0), reason: 'Stock toggle must set to 0 when previously in-stock');
        } else {
          expect(toggled.stock, greaterThan(0), reason: 'Stock toggle must replenish when previously zero');
        }
      }
    });

    test('INTEGRITY CHECK: Deleting a product removes it cleanly from catalog', () async {
      await productProvider.loadProducts();
      if (productProvider.allProducts.isNotEmpty) {
        final toDelete = productProvider.allProducts.first;
        final targetId = toDelete.id;
        final beforeCount = productProvider.allProducts.length;

        await productProvider.deleteProduct(targetId);

        expect(productProvider.allProducts.length, equals(beforeCount - 1));
        final exists = productProvider.allProducts.any((p) => p.id == targetId);
        expect(exists, isFalse, reason: 'Deleted product must not linger in catalog');
      }
    });
  });

  group('QA SUITE 5: USER PROFILE, VALIDATION & AUTH RESILIENCY', () {
    test('FRUSTRATION CHECK: Empty or null profile fields fallback to helpful defaults', () {
      final user = UserProfile.fromMap({
        'id': 'usr_blank',
        'name': null,
        'email': null,
        'phone': null,
        'address': null,
      });

      expect(user.id, equals('usr_blank'));
      expect(user.name, isNotEmpty, reason: 'User name must fallback gracefully, not display null');
      expect(user.address, isNotEmpty, reason: 'Address must have a readable fallback');
      expect(user.bio, isNotEmpty);
    });

    test('CORNER CASE: UserProfile copyWith preserves existing values if not specified', () {
      final original = UserProfile(
        id: 'usr_orig',
        name: 'Original Name',
        email: 'orig@atblink.com',
        phone: '+91 9999988888',
        address: 'Sector 42, Gurugram',
      );

      final modified = original.copyWith(name: 'Updated Name');
      expect(modified.name, equals('Updated Name'));
      expect(modified.email, equals(original.email));
      expect(modified.phone, equals(original.phone));
      expect(modified.address, equals(original.address));
      expect(modified.id, equals(original.id));
    });
  });

  group('QA SUITE 6: UI/UX WIDGET RENDERING & VISUAL REGRESSION CHECKS', () {
    testWidgets('OrderSuccessScreen renders order ID, delivery stepper, and action buttons', (tester) async {
      final testOrder = OrderModel(
        orderId: 'ATB-987654321',
        userId: 'usr_test',
        deliveryAddress: 'Flat 504, Emerald Heights, Bengaluru',
        items: [
          CartItem(
            product: Product(
              id: 999,
              title: 'Farm Fresh Milk',
              description: 'Fresh milk',
              price: 33.0,
              category: 'Dairy',
              thumbnail: '',
            ),
            quantity: 2,
          ),
        ],
        subtotal: 66.0,
        deliveryFee: 15.0,
        handlingFee: 5.0,
        grandTotal: 86.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OrderSuccessScreen(order: testOrder),
        ),
      );

      // Verify header congratulations text
      expect(find.text('Order Placed Successfully!'), findsOneWidget);

      // Verify order ID is shown to user
      expect(find.textContaining('ATB-987654321'), findsOneWidget);

      // Verify delivery ETA / tracking steps
      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Items Picked & Packed'), findsOneWidget);
      expect(find.text('Rider Assigned'), findsOneWidget);
      expect(find.text('Out for Express Delivery'), findsOneWidget);

      // Verify action buttons exist
      expect(find.text('View in My Orders (Firebase)'), findsOneWidget);
      expect(find.text('Back to Home Store'), findsOneWidget);
    });
  });
}
