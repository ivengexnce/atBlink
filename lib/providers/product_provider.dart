import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/rest_api_service.dart';

class ProductProvider extends ChangeNotifier {
  final RestApiService _apiService = RestApiService();
  final FirestoreService _firestoreService = FirestoreService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _isFirestoreSynced = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  bool get isFirestoreSynced => _isFirestoreSynced;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get flashDeals =>
      _products.where((p) => p.discountPercentage >= 10.0).toList();

  final List<CategoryItem> categories = const [
    CategoryItem(
      id: 'all',
      name: 'All',
      iconData: Icons.grid_view_rounded,
      backgroundColor: Color(0xFFFFF3E0),
    ),
    CategoryItem(
      id: 'vegetables',
      name: 'Vegetables',
      iconData: Icons.eco_rounded,
      backgroundColor: Color(0xFFE8F5E9),
    ),
    CategoryItem(
      id: 'dairy',
      name: 'Dairy',
      iconData: Icons.local_drink_rounded,
      backgroundColor: Color(0xFFE3F2FD),
    ),
    CategoryItem(
      id: 'snacks',
      name: 'Snacks',
      iconData: Icons.fastfood_rounded,
      backgroundColor: Color(0xFFFFF8E1),
    ),
    CategoryItem(
      id: 'drinks',
      name: 'Drinks',
      iconData: Icons.local_cafe_rounded,
      backgroundColor: Color(0xFFE1F5FE),
    ),
    CategoryItem(
      id: 'fruits',
      name: 'Fruits',
      iconData: Icons.apple_rounded,
      backgroundColor: Color(0xFFFFEBEE),
    ),
    CategoryItem(
      id: 'bakery',
      name: 'Bakery',
      iconData: Icons.bakery_dining_rounded,
      backgroundColor: Color(0xFFF3E5F5),
    ),
    CategoryItem(
      id: 'personal_care',
      name: 'Personal Care',
      iconData: Icons.clean_hands_rounded,
      backgroundColor: Color(0xFFF0F4C3),
    ),
  ];

  int _loadOperationId = 0;

  ProductProvider({bool autoLoad = true}) {
    if (autoLoad) {
      loadProducts();
    }
  }

  Future<void> loadProducts({String? category, String? query, bool fallbackIfEmpty = false}) async {
    final opId = ++_loadOperationId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (category != null) _selectedCategory = category;
      if (query != null) _searchQuery = query;

      // 1. Check live Firestore & local admin-managed products
      final storeProducts = await _firestoreService.fetchProducts();
      if (opId != _loadOperationId) return;

      if (storeProducts.isNotEmpty) {
        _products = storeProducts;
        _isFirestoreSynced = true;
      } else if (fallbackIfEmpty) {
        _products = _apiService.getQuickCommerceCatalog(
          category: _selectedCategory,
          searchQuery: _searchQuery,
        );
        _isFirestoreSynced = false;
      } else {
        _products = [];
        _isFirestoreSynced = false;
      }

      _applyFilters();
    } catch (e) {
      if (opId != _loadOperationId) return;
      _errorMessage = 'Failed to load products: $e';
    } finally {
      if (opId == _loadOperationId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Load existing products into Admin Hub so admin can categorize, edit, add, or remove
  Future<void> loadProductsForAdmin() async {
    final opId = ++_loadOperationId;
    _isLoading = true;
    notifyListeners();
    try {
      final storeProducts = await _firestoreService.fetchProducts();
      if (opId != _loadOperationId) return;

      if (storeProducts.isNotEmpty) {
        _products = storeProducts;
        _isFirestoreSynced = true;
      } else {
        // Pre-populate Admin with the existing catalog so Admin can manage, categorize, edit & remove!
        _products = _apiService.getQuickCommerceCatalog();
        _isFirestoreSynced = false;
        await _firestoreService.cacheProductsLocally(_products);
      }
      _applyFilters();
    } catch (e) {
      if (opId != _loadOperationId) return;
      debugPrint('Error loading products for admin: $e');
    } finally {
      if (opId == _loadOperationId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Quick re-categorization of an existing product
  Future<void> recategorizeProduct(int productId, String newCategory) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final updated = _products[index].copyWith(category: newCategory);
    _products[index] = updated;
    _applyFilters();
    notifyListeners();
    await _firestoreService.saveProduct(updated);
  }

  /// Restore default quick-commerce catalog into Admin & Store
  Future<int> restoreDefaultCatalog() async {
    _isLoading = true;
    notifyListeners();
    try {
      final defaultItems = _apiService.getQuickCommerceCatalog();
      final count = await _firestoreService.bulkSeedProducts(defaultItems);
      _products = defaultItems;
      _isFirestoreSynced = true;
      _applyFilters();
      return count;
    } catch (e) {
      debugPrint('Error restoring default catalog: $e');
      return 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new product to Firestore and local state
  Future<bool> addProduct(Product product) async {
    try {
      final newId = product.id != 0
          ? product.id
          : (DateTime.now().millisecondsSinceEpoch % 900000) + 100000;
      final newProduct = product.copyWith(id: newId);

      final success = await _firestoreService.saveProduct(newProduct);
      _products.insert(0, newProduct);
      _isFirestoreSynced = true;
      _applyFilters();
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return false;
    }
  }

  /// Update an existing product in Firestore and local state
  Future<bool> updateProduct(Product product) async {
    try {
      final success = await _firestoreService.saveProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilters();
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  /// Delete a product from Firestore and local state
  Future<bool> deleteProduct(int productId) async {
    try {
      final success = await _firestoreService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _applyFilters();
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  /// Quick toggle stock status (e.g. In Stock <-> Out of Stock)
  Future<void> toggleStock(int productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final current = _products[index];
    final updated = current.copyWith(stock: current.stock > 0 ? 0 : 50);
    _products[index] = updated;
    _applyFilters();
    notifyListeners();
    await _firestoreService.saveProduct(updated);
  }

  /// Bulk seed the entire catalog into Firebase Firestore in one atomic batch
  Future<int> bulkSeedToFirestore() async {
    _isLoading = true;
    notifyListeners();
    try {
      final catalog = await _apiService.fetchProducts(category: 'All');
      final seededCount = await _firestoreService.bulkSeedProducts(catalog);
      if (seededCount > 0) {
        _products = await _firestoreService.fetchProducts();
        _isFirestoreSynced = true;
        _applyFilters();
      }
      return seededCount;
    } catch (e) {
      debugPrint('Error bulk seeding products: $e');
      return 0;
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

  void resetCategory() => selectCategory('All');

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();
    final cat = _selectedCategory.trim().toLowerCase();
    final isAll = cat == 'all';

    _filteredProducts = _products.where((p) {
      final matchesCategory = isAll || p.category.trim().toLowerCase() == cat;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return p.title.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query);
    }).toList();
  }
}
