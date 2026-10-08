import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../utils/constants.dart';

class RestApiService {
  static const String _baseUrl = AppConstants.restApiBaseUrl;

  /// Fetch products from quick-commerce catalog with optional online enrichments
  Future<List<Product>> fetchProducts({String? category, String? searchQuery}) async {
    final catalog = _getMockQuickCommerceProducts(category: category, searchQuery: searchQuery);

    // If internet is reachable, attempt to fetch extra online products from DummyJSON
    try {
      String url = '$_baseUrl${AppConstants.productsEndpoint}?limit=30';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url = '$_baseUrl/products/search?q=${Uri.encodeComponent(searchQuery)}';
      }

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('products')) {
          final List<dynamic> productsJson = data['products'];
          List<Product> onlineProducts = [];
          
          for (final j in productsJson) {
            Product p = Product.fromJson(j);
            // Map remote dummy categories into quick-commerce categories
            String mappedCategory = p.category;
            final catLower = p.category.toLowerCase();
            if (catLower.contains('grocer') || catLower.contains('food')) {
              mappedCategory = 'Snacks';
            } else if (catLower.contains('beauty') || catLower.contains('skin') || catLower.contains('fragrance')) {
              mappedCategory = 'Personal Care';
            } else {
              continue; // Skip non-grocery items like furniture or laptops
            }

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
                category: mappedCategory,
                thumbnail: p.thumbnail,
                unitQuantity: p.unitQuantity,
                deliveryEta: p.deliveryEta,
              );
            }
            onlineProducts.add(p);
          }

          if (onlineProducts.isNotEmpty) {
            final combined = [...catalog, ...onlineProducts];
            if (category != null && category.isNotEmpty && category != 'All') {
              return combined
                  .where((p) => p.category.toLowerCase() == category.toLowerCase())
                  .toList();
            }
            return combined;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('REST API network notice ($e). Using high-speed local catalog.');
      }
    }

    return catalog;
  }

  /// Comprehensive Quick Commerce catalog in Indian Rupees (₹)
  List<Product> _getMockQuickCommerceProducts({String? category, String? searchQuery}) {
    final allProducts = [
      // DAIRY
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
        title: 'Amul Pasteurised Salted Butter',
        description: 'Utterly butterly delicious fresh table butter.',
        price: 58.0,
        discountPercentage: 6,
        rating: 4.9,
        stock: 80,
        brand: 'Amul',
        category: 'Dairy',
        thumbnail: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop',
        unitQuantity: '100 g',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 103,
        title: 'Mother Dairy Classic Malai Paneer',
        description: 'Rich, soft and creamy fresh cottage cheese cubes.',
        price: 92.0,
        discountPercentage: 10,
        rating: 4.7,
        stock: 45,
        brand: 'Mother Dairy',
        category: 'Dairy',
        thumbnail: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop',
        unitQuantity: '200 g',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 104,
        title: 'Nandini Fresh Curd / Dahi',
        description: 'Thick, creamy and pasteurised rich homestyle dahi.',
        price: 35.0,
        discountPercentage: 8,
        rating: 4.6,
        stock: 90,
        brand: 'Nandini',
        category: 'Dairy',
        thumbnail: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop',
        unitQuantity: '400 g',
        deliveryEta: '8 MINS',
      ),

      // VEGETABLES
      Product(
        id: 201,
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
        id: 202,
        title: 'Fresh Hybrid Potatoes (Aloo)',
        description: 'Dirt-free, clean skin premium grade Indian potatoes.',
        price: 38.0,
        discountPercentage: 15,
        rating: 4.7,
        stock: 120,
        brand: 'atBlink Fresh',
        category: 'Vegetables',
        thumbnail: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop',
        unitQuantity: '1 kg',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 203,
        title: 'Fresh Nashik Red Onions (Pyaaz)',
        description: 'Pungent, flavorful and sun-cured medium red onions.',
        price: 42.0,
        discountPercentage: 12,
        rating: 4.5,
        stock: 110,
        brand: 'atBlink Fresh',
        category: 'Vegetables',
        thumbnail: 'https://images.unsplash.com/photo-1508747703725-719777637510?w=500&auto=format&fit=crop',
        unitQuantity: '1 kg',
        deliveryEta: '9 MINS',
      ),
      Product(
        id: 204,
        title: 'Fresh Green Capsicum (Shimla Mirch)',
        description: 'Crisp, shiny and juicy farm-fresh green bell peppers.',
        price: 48.0,
        discountPercentage: 18,
        rating: 4.6,
        stock: 50,
        brand: 'atBlink Fresh',
        category: 'Vegetables',
        thumbnail: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500&auto=format&fit=crop',
        unitQuantity: '500 g',
        deliveryEta: '10 MINS',
      ),

      // SNACKS
      Product(
        id: 301,
        title: 'Lay\'s India\'s Magic Masala Chips',
        description: 'Crispy potato chips spiced with authentic Indian spices.',
        price: 20.0,
        discountPercentage: 10,
        rating: 4.9,
        stock: 150,
        brand: 'Lay\'s',
        category: 'Snacks',
        thumbnail: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&auto=format&fit=crop',
        unitQuantity: '115 g',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 302,
        title: 'Haldiram\'s Nagpur Bhujia Sev',
        description: 'Crispy spiced moth bean flour noodles fried in vegetable oil.',
        price: 55.0,
        discountPercentage: 8,
        rating: 4.8,
        stock: 95,
        brand: 'Haldiram\'s',
        category: 'Snacks',
        thumbnail: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop',
        unitQuantity: '200 g',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 303,
        title: 'Maggi 2-Minute Masala Noodles',
        description: 'Classic favorite instant noodles with signature spice mix.',
        price: 60.0,
        discountPercentage: 10,
        rating: 4.9,
        stock: 200,
        brand: 'Nestle',
        category: 'Snacks',
        thumbnail: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=500&auto=format&fit=crop',
        unitQuantity: '4 Pack (280g)',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 304,
        title: 'Kurkure Masala Munch Crisps',
        description: 'Crunchy tedhe-medhe corn puffs spiced with hot masala.',
        price: 20.0,
        discountPercentage: 5,
        rating: 4.7,
        stock: 140,
        brand: 'Kurkure',
        category: 'Snacks',
        thumbnail: 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=500&auto=format&fit=crop',
        unitQuantity: '90 g',
        deliveryEta: '7 MINS',
      ),

      // DRINKS
      Product(
        id: 401,
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
        id: 402,
        title: 'Sprite Lemon-Lime Cold Can',
        description: 'Crisp, refreshing lemon-lime flavored fizzy soda.',
        price: 40.0,
        discountPercentage: 10,
        rating: 4.6,
        stock: 75,
        brand: 'Sprite',
        category: 'Drinks',
        thumbnail: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=500&auto=format&fit=crop',
        unitQuantity: '300 ml',
        deliveryEta: '8 MINS',
      ),
      Product(
        id: 403,
        title: 'Tropicana 100% Real Orange Juice',
        description: 'Pure, no added sugar, Vitamin-C rich breakfast juice.',
        price: 125.0,
        discountPercentage: 12,
        rating: 4.8,
        stock: 40,
        brand: 'Tropicana',
        category: 'Drinks',
        thumbnail: 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=500&auto=format&fit=crop',
        unitQuantity: '1 L',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 404,
        title: 'Nescafé Chilled Hazelnut Cold Coffee',
        description: 'Creamy and refreshing ready-to-drink roasted bean coffee.',
        price: 45.0,
        discountPercentage: 10,
        rating: 4.8,
        stock: 65,
        brand: 'Nescafé',
        category: 'Drinks',
        thumbnail: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&auto=format&fit=crop',
        unitQuantity: '180 ml',
        deliveryEta: '8 MINS',
      ),

      // FRUITS
      Product(
        id: 501,
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
        id: 502,
        title: 'Fresh Robusta Yellow Bananas',
        description: 'Naturally ripened, sweet and potassium rich bananas.',
        price: 59.0,
        discountPercentage: 10,
        rating: 4.8,
        stock: 70,
        brand: 'atBlink Fresh',
        category: 'Fruits',
        thumbnail: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop',
        unitQuantity: '1 kg (approx 6 pcs)',
        deliveryEta: '9 MINS',
      ),
      Product(
        id: 503,
        title: 'Fresh Green Seedless Grapes',
        description: 'Crisp, sweet and seedless fresh table grapes.',
        price: 89.0,
        discountPercentage: 15,
        rating: 4.6,
        stock: 45,
        brand: 'atBlink Fresh',
        category: 'Fruits',
        thumbnail: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=500&auto=format&fit=crop',
        unitQuantity: '500 g',
        deliveryEta: '10 MINS',
      ),

      // BAKERY
      Product(
        id: 601,
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
        id: 602,
        title: 'The Health Factory Zero Maida Bread',
        description: 'Healthy artisan zero maida protein bread.',
        price: 65.0,
        discountPercentage: 5,
        rating: 4.7,
        stock: 35,
        brand: 'The Health Factory',
        category: 'Bakery',
        thumbnail: 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=500&auto=format&fit=crop',
        unitQuantity: '350 g',
        deliveryEta: '11 MINS',
      ),
      Product(
        id: 603,
        title: 'Cadbury Chocobakes Layered Cake',
        description: 'Soft chocolate sponge layered with rich Cadbury cream.',
        price: 60.0,
        discountPercentage: 10,
        rating: 4.9,
        stock: 80,
        brand: 'Cadbury',
        category: 'Bakery',
        thumbnail: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop',
        unitQuantity: '126 g',
        deliveryEta: '8 MINS',
      ),

      // PERSONAL CARE
      Product(
        id: 701,
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
      Product(
        id: 702,
        title: 'Dettol Liquid Handwash Pump',
        description: '100% better germ protection with gentle skin moisturizers.',
        price: 99.0,
        discountPercentage: 15,
        rating: 4.8,
        stock: 75,
        brand: 'Dettol',
        category: 'Personal Care',
        thumbnail: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop',
        unitQuantity: '200 ml',
        deliveryEta: '10 MINS',
      ),
      Product(
        id: 703,
        title: 'Colgate Strong Teeth Dental Toothpaste',
        description: 'Amino Shakti formula for calcium boost and cavity protection.',
        price: 85.0,
        discountPercentage: 12,
        rating: 4.7,
        stock: 90,
        brand: 'Colgate',
        category: 'Personal Care',
        thumbnail: 'https://images.unsplash.com/photo-1559650656-5d1d427756a9?w=500&auto=format&fit=crop',
        unitQuantity: '150 g',
        deliveryEta: '9 MINS',
      ),
      Product(
        id: 704,
        title: 'Dove Deep Moisture Shampoo',
        description: 'Pro-Moisture complex for 10x smoother and shinier hair.',
        price: 145.0,
        discountPercentage: 20,
        rating: 4.7,
        stock: 50,
        brand: 'Dove',
        category: 'Personal Care',
        thumbnail: 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=500&auto=format&fit=crop',
        unitQuantity: '180 ml',
        deliveryEta: '11 MINS',
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
