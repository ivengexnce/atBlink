import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../utils/constants.dart';

class RestApiService {
  static const String _baseUrl = AppConstants.restApiBaseUrl;

  /// Fetch products from REST API with fallback to quick-commerce mock catalog
  Future<List<Product>> fetchProducts({String? category, String? searchQuery}) async {
    try {
      String url = '$_baseUrl${AppConstants.productsEndpoint}?limit=30';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url = '$_baseUrl/products/search?q=${Uri.encodeComponent(searchQuery)}';
      } else if (category != null && category.isNotEmpty && category != 'All') {
        url = '$_baseUrl/products/category/${Uri.encodeComponent(category.toLowerCase())}';
      }

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('products')) {
          final List<dynamic> productsJson = data['products'];
          List<Product> products = productsJson.map((j) {
            Product p = Product.fromJson(j);
            // Convert USD price from REST API to INR Rupees if < 100
            if (p.price < 100) {
              p = Product(
                id: p.id,
                title: p.title,
                description: p.description,
                price: (p.price * 80).roundToDouble(),
                discountPercentage: p.discountPercentage,
                rating: p.rating,
                stock: p.stock,
                brand: p.brand,
                category: p.category,
                thumbnail: p.thumbnail,
                unitQuantity: p.unitQuantity,
                deliveryEta: p.deliveryEta,
              );
            }
            return p;
          }).toList();
          
          if (products.isNotEmpty) {
            return products;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('REST API error or offline ($e). Loading fallback catalog.');
      }
    }

    // Fallback Quick Commerce catalog in Rupees (₹)
    return _getMockQuickCommerceProducts(category: category, searchQuery: searchQuery);
  }

  /// Mock quick commerce catalog in Indian Rupees (₹)
  List<Product> _getMockQuickCommerceProducts({String? category, String? searchQuery}) {
    final allProducts = [
      Product(
        id: 101,
        title: 'Amul Taaza Toned Fresh Milk',
        description: 'Pasteurised Toned Milk. Essential daily fresh dairy.',
        price: 33.0,
        discountPercentage: 5,
        rating: 4.8,
        stock: 100,
        brand: 'Amul',
        category: 'Dairy',
        thumbnail: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop',
        unitQuantity: '500 ml',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 102,
        title: 'Fresh Farm Hydroponic Tomatoes',
        description: 'Organically grown firm red ripe tomatoes, fresh from farm.',
        price: 45.0,
        discountPercentage: 20,
        rating: 4.6,
        stock: 60,
        brand: 'atBlink Fresh',
        category: 'Vegetables',
        thumbnail: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop',
        unitQuantity: '500 g',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 103,
        title: 'Lay\'s India\'s Magic Masala Chips',
        description: 'Crispy potato chips spiced with authentic Indian spices.',
        price: 20.0,
        discountPercentage: 10,
        rating: 4.9,
        stock: 120,
        brand: 'Lay\'s',
        category: 'Snacks',
        thumbnail: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop',
        unitQuantity: '115 g',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 104,
        title: 'Coca-Cola Zero Sugar Can',
        description: 'Refreshing ice cold carbonated soft drink zero sugar.',
        price: 40.0,
        discountPercentage: 15,
        rating: 4.7,
        stock: 80,
        brand: 'Coca-Cola',
        category: 'Drinks',
        thumbnail: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=500&auto=format&fit=crop',
        unitQuantity: '300 ml',
        deliveryEta: '9 MINS',
      ),
      Product(
        id: 105,
        title: 'Fresh Washington Red Apples',
        description: 'Sweet, crisp and juicy red delicious apples.',
        price: 149.0,
        discountPercentage: 12,
        rating: 4.7,
        stock: 40,
        brand: 'atBlink Fresh',
        category: 'Fruits',
        thumbnail: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop',
        unitQuantity: '4 pcs (approx 600g)',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 106,
        title: 'Britannia Whole Wheat Sandwich Bread',
        description: 'Soft 100% whole wheat bread loaf packed with fiber.',
        price: 50.0,
        discountPercentage: 8,
        rating: 4.5,
        stock: 50,
        brand: 'Britannia',
        category: 'Bakery',
        thumbnail: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop',
        unitQuantity: '400 g',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 107,
        title: 'Maggi 2-Minute Masala Noodles',
        description: 'Classic favorite instant noodles with signature spice mix.',
        price: 60.0,
        discountPercentage: 10,
        rating: 4.9,
        stock: 200,
        brand: 'Nestle',
        category: 'Instant Food',
        thumbnail: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop',
        unitQuantity: '4 Pack (280g)',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 108,
        title: 'Nivea Deep Impact Shower Gel',
        description: 'Refreshing body wash with microfine clay for deep cleansing.',
        price: 199.0,
        discountPercentage: 25,
        rating: 4.6,
        stock: 35,
        brand: 'Nivea',
        category: 'Personal Care',
        thumbnail: 'https://images.unsplash.com/photo-1585238342024-78d387f4a707?w=500&auto=format&fit=crop',
        unitQuantity: '250 ml',
        deliveryEta: '12 MINS',
      ),
    ];

    List<Product> results = allProducts;

    if (category != null && category.isNotEmpty && category != 'All') {
      results = results
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((p) =>
          p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q)
      ).toList();
    }

    return results;
  }
}
