import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/rest_api_service.dart';

class ProductProvider extends ChangeNotifier {
  final RestApiService _apiService = RestApiService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get flashDeals =>
      _products.where((p) => p.discountPercentage >= 10.0).toList();

  final List<CategoryItem> categories = [
    CategoryItem(
      id: 'all',
      name: 'All',
      iconData: Icons.grid_view_rounded,
      backgroundColor: const Color(0xFFFFF3E0),
    ),
    CategoryItem(
      id: 'vegetables',
      name: 'Vegetables',
      iconData: Icons.eco_rounded,
      backgroundColor: const Color(0xFFE8F5E9),
    ),
    CategoryItem(
      id: 'dairy',
      name: 'Dairy',
      iconData: Icons.local_drink_rounded,
      backgroundColor: const Color(0xFFE3F2FD),
    ),
    CategoryItem(
      id: 'snacks',
      name: 'Snacks',
      iconData: Icons.fastfood_rounded,
      backgroundColor: const Color(0xFFFFF8E1),
    ),
    CategoryItem(
      id: 'drinks',
      name: 'Drinks',
      iconData: Icons.local_cafe_rounded,
      backgroundColor: const Color(0xFFE1F5FE),
    ),
    CategoryItem(
      id: 'fruits',
      name: 'Fruits',
      iconData: Icons.apple_rounded,
      backgroundColor: const Color(0xFFFFEBEE),
    ),
    CategoryItem(
      id: 'bakery',
      name: 'Bakery',
      iconData: Icons.bakery_dining_rounded,
      backgroundColor: const Color(0xFFF3E5F5),
    ),
    CategoryItem(
      id: 'personal_care',
      name: 'Personal Care',
      iconData: Icons.clean_hands_rounded,
      backgroundColor: const Color(0xFFF0F4C3),
    ),
  ];

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts({String? category, String? query}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (category != null) _selectedCategory = category;
      if (query != null) _searchQuery = query;

      _products = await _apiService.fetchProducts(
        category: _selectedCategory,
        searchQuery: _searchQuery,
      );

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    if (_products.isNotEmpty) {
      _applyFilters();
      notifyListeners();
    } else {
      loadProducts(category: category);
    }
  }

  void resetCategory() {
    selectCategory('All');
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      bool matchesCategory = (_selectedCategory == 'All') ||
          (product.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase());
      bool matchesQuery = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
