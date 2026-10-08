import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:atblink/models/cart_item_model.dart';
import 'package:atblink/models/order_model.dart';
import 'package:atblink/models/product_model.dart';
import 'package:atblink/models/review_model.dart';
import 'package:atblink/models/user_profile_model.dart';
import 'package:atblink/providers/cart_provider.dart';
import 'package:atblink/providers/product_provider.dart';
import 'package:atblink/services/rest_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product Model Tests', () {
    test('Product parses from JSON properly with defaults', () {
      final json = {
        'id': 1,
        'title': 'Test Milk',
        'description': 'Fresh cow milk',
        'price': 40,
        'discountPercentage': 12.5,
        'rating': 4.7,
        'stock': 50,
        'brand': 'Amul',
        'category': 'dairy',
        'thumbnail': 'https://example.com/milk.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.id, equals(1));
      expect(product.title, equals('Test Milk'));
      expect(product.price, equals(40.0));
      expect(product.discountPercentage, equals(12.5));
      expect(product.stock, equals(50));
      expect(product.brand, equals('Amul'));
      expect(product.category, equals('dairy'));
      expect(product.deliveryEta, equals('10 MINS'));
    });

    test('Product calculates discounted price correctly', () {
      final product = Product(
        id: 2,
        title: 'Apples',
        description: 'Fresh red apples',
        price: 100.0,
        discountPercentage: 20.0,
        rating: 4.5,
        stock: 30,
        brand: 'atBlink Fresh',
        category: 'Fruits',
        thumbnail: '',
      );

      // Price is 100, 20% discount => 80.0
      expect(product.discountedPrice, equals(80.0));
    });
  });

  group('UserProfile Model Tests', () {
    test('UserProfile serialization, deserialization, and copyWith', () {
      final user = UserProfile(
        id: 'usr_123',
        name: 'Rahul Sharma',
        email: 'rahul@atblink.com',
        phone: '+91 9876543210',
        address: 'Tower A, DLF Cyber City, Gurugram',
        bio: 'Fast grocery shopper ⚡',
        authMethod: 'google',
      );

      final map = user.toMap();
      expect(map['id'], equals('usr_123'));
      expect(map['name'], equals('Rahul Sharma'));
      expect(map['authMethod'], equals('google'));

      final restored = UserProfile.fromMap(map);
      expect(restored.id, equals(user.id));
      expect(restored.name, equals(user.name));
      expect(restored.address, equals(user.address));

      final updated = user.copyWith(name: 'Rahul S.');
      expect(updated.name, equals('Rahul S.'));
      expect(updated.email, equals(user.email));
    });
  });

  group('Cart Calculation & CartProvider Automation Tests', () {
    late CartProvider cartProvider;

    final mockProduct1 = Product(
      id: 101,
      title: 'Amul Taaza Milk',
      description: '500ml',
      price: 30.0,
      discountPercentage: 0,
      rating: 4.8,
      stock: 100,
      brand: 'Amul',
      category: 'Dairy',
      thumbnail: '',
    );

    final mockProduct2 = Product(
      id: 102,
      title: 'Hydroponic Tomatoes',
      description: '500g',
      price: 50.0,
      discountPercentage: 0,
      rating: 4.6,
      stock: 50,
      brand: 'atBlink',
      category: 'Vegetables',
      thumbnail: '',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cartProvider = CartProvider();
    });

    test('Initial cart is empty with zero fees', () {
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.subtotal, equals(0.0));
      expect(cartProvider.deliveryFee, equals(0.0));
      expect(cartProvider.handlingFee, equals(0.0));
      expect(cartProvider.grandTotal, equals(0.0));
    });

    test('Adding product increments quantity and computes bill with standard delivery', () {
      cartProvider.addToCart(mockProduct1);

      expect(cartProvider.itemCount, equals(1));
      expect(cartProvider.getProductQuantity(101), equals(1));
      expect(cartProvider.subtotal, equals(30.0));
      // Subtotal <= 199 => delivery fee is 15.0
      expect(cartProvider.deliveryFee, equals(15.0));
      // Subtotal > 0 => handling fee is 5.0
      expect(cartProvider.handlingFee, equals(5.0));
      // Grand Total = 30 + 15 + 5 = 50.0
      expect(cartProvider.grandTotal, equals(50.0));
    });

    test('Quantity increment and free delivery threshold (> ₹199)', () {
      // Add 4 x mockProduct2 (4 * 50 = 200.0)
      cartProvider.addToCart(mockProduct2);
      cartProvider.addToCart(mockProduct2);
      cartProvider.addToCart(mockProduct2);
      cartProvider.addToCart(mockProduct2);

      expect(cartProvider.getProductQuantity(102), equals(4));
      expect(cartProvider.subtotal, equals(200.0));
      // Subtotal > 199 => Delivery is Free!
      expect(cartProvider.deliveryFee, equals(0.0));
      expect(cartProvider.handlingFee, equals(5.0));
      // Grand Total = 200 + 0 + 5 = 205.0
      expect(cartProvider.grandTotal, equals(205.0));
    });

    test('Decrementing and removing items works accurately', () {
      cartProvider.addToCart(mockProduct1);
      cartProvider.addToCart(mockProduct1);
      expect(cartProvider.getProductQuantity(101), equals(2));

      cartProvider.removeFromCart(101);
      expect(cartProvider.getProductQuantity(101), equals(1));

      cartProvider.removeFromCart(101);
      expect(cartProvider.getProductQuantity(101), equals(0));
      expect(cartProvider.itemCount, equals(0));
    });

    test('Clear cart empties all state', () {
      cartProvider.addToCart(mockProduct1);
      cartProvider.addToCart(mockProduct2);
      expect(cartProvider.itemCount, equals(2));

      cartProvider.clearCart();
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.grandTotal, equals(0.0));
    });
  });

  group('ProductProvider Filtering & Search Automation Tests', () {
    late ProductProvider productProvider;

    setUp(() {
      productProvider = ProductProvider();
    });

    test('Categories are initialized with 8 distinct categories', () {
      expect(productProvider.categories.length, equals(8));
      expect(productProvider.categories.first.name, equals('All'));
    });

    test('Search query filter matches title or brand', () async {
      // Wait for mock fallback / products to load
      await productProvider.loadProducts();

      productProvider.setSearchQuery('Milk');
      for (final p in productProvider.products) {
        final matches = p.title.toLowerCase().contains('milk') ||
            p.category.toLowerCase().contains('milk') ||
            p.brand.toLowerCase().contains('milk');
        expect(matches, isTrue);
      }
    });

    test('Flash deals filter returns only discounted items (>= 10%)', () async {
      await productProvider.loadProducts();

      for (final deal in productProvider.flashDeals) {
        expect(deal.discountPercentage, greaterThanOrEqualTo(10.0));
      }
    });

    test('selectCategory filters instantly and resetCategory resets to All', () async {
      await productProvider.loadProducts();

      // Test select category
      productProvider.selectCategory('Snacks');
      expect(productProvider.selectedCategory, equals('Snacks'));
      expect(productProvider.products, isNotEmpty);
      for (final p in productProvider.products) {
        expect(p.category.toLowerCase(), equals('snacks'));
      }

      // Test reset category
      productProvider.resetCategory();
      expect(productProvider.selectedCategory, equals('All'));
      expect(productProvider.products.length, greaterThan(productProvider.products.where((p) => p.category == 'Snacks').length));
    });
  });

  group('RestApiService Fallback Resiliency Tests', () {
    test('Returns quick-commerce mock products when category is selected', () async {
      final service = RestApiService();

      final dairyProducts = await service.fetchProducts(category: 'Dairy');
      expect(dairyProducts, isNotEmpty);
      for (final p in dairyProducts) {
        expect(p.category.toLowerCase(), equals('dairy'));
      }

      final vegProducts = await service.fetchProducts(category: 'Vegetables');
      expect(vegProducts, isNotEmpty);
      for (final p in vegProducts) {
        expect(p.category.toLowerCase(), equals('vegetables'));
      }
    });

    test('Every quick-commerce category has authentic non-empty products without merging', () async {
      final service = RestApiService();
      final categoriesToCheck = ['Dairy', 'Vegetables', 'Snacks', 'Drinks', 'Fruits', 'Bakery', 'Personal Care'];

      for (final cat in categoriesToCheck) {
        final products = await service.fetchProducts(category: cat);
        expect(products, isNotEmpty, reason: 'Category $cat should not be empty');
        for (final p in products) {
          expect(p.category.toLowerCase(), equals(cat.toLowerCase()), reason: 'Product $p should belong strictly to $cat');
        }
      }
    });
  });

  group('ReviewModel & Rating Tests', () {
    test('ReviewModel serialization and deserialization', () {
      final review = ReviewModel(
        id: 'rev_123',
        productId: 101,
        userId: 'user_456',
        userName: 'Aarav Sharma',
        rating: 4.5,
        comment: 'Fresh quality milk, delivered in 7 mins!',
      );

      final map = review.toMap();
      expect(map['id'], equals('rev_123'));
      expect(map['productId'], equals(101));
      expect(map['rating'], equals(4.5));
      expect(map['comment'], equals('Fresh quality milk, delivered in 7 mins!'));

      final fromMap = ReviewModel.fromMap(map);
      expect(fromMap.id, equals('rev_123'));
      expect(fromMap.productId, equals(101));
      expect(fromMap.userName, equals('Aarav Sharma'));
      expect(fromMap.rating, equals(4.5));
    });
  });

  group('OrderModel & OrderProvider Tests', () {
    test('OrderModel serialization and order ID generation', () {
      final product = Product(
        id: 1,
        title: 'Banana Bunch',
        description: 'Fresh bananas',
        price: 50.0,
        discountPercentage: 0.0,
        rating: 4.8,
        stock: 20,
        brand: 'FreshFarm',
        category: 'Fruits',
        thumbnail: '',
      );

      final cartItem = CartItem(product: product, quantity: 2);
      final orderId = OrderModel.generateOrderId();

      final order = OrderModel(
        orderId: orderId,
        userId: 'user_test_99',
        items: [cartItem],
        subtotal: 100.0,
        deliveryFee: 0.0,
        handlingFee: 2.0,
        grandTotal: 102.0,
        deliveryAddress: 'Flat 101, Palm Grove, Bengaluru',
      );

      expect(order.orderId.startsWith('ATB-'), isTrue);
      expect(order.items.length, equals(1));
      expect(order.grandTotal, equals(102.0));

      final map = order.toMap();
      expect(map['userId'], equals('user_test_99'));
      expect(map['itemCount'], equals(2));
      expect(map['grandTotal'], equals(102.0));

      final fromMap = OrderModel.fromMap(map);
      expect(fromMap.orderId, equals(orderId));
      expect(fromMap.userId, equals('user_test_99'));
      expect(fromMap.items.first.product.title, equals('Banana Bunch'));
    });
  });
}
