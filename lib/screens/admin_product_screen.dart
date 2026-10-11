import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categoryOptions = [
    'Vegetables',
    'Dairy',
    'Snacks',
    'Drinks',
    'Fruits',
    'Bakery',
    'Personal Care',
    'Groceries',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductsForAdmin();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.allProducts;

    // Apply local category and search filters
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = allProducts.where((p) {
      final matchesCat = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      if (!matchesCat) return false;
      if (query.isEmpty) return true;
      return p.title.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();

    final inStockCount = allProducts.where((p) => p.stock > 0).length;
    final outOfStockCount = allProducts.length - inStockCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Products Hub',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage Firestore Catalog & Categories',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Publish / Sync All to Firestore',
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => _confirmBulkSeed(context, productProvider),
          ),
          IconButton(
            tooltip: 'Restore 25 Default Items',
            icon: const Icon(Icons.restore_page_outlined),
            onPressed: () => _confirmRestoreDefault(context, productProvider),
          ),
          IconButton(
            tooltip: 'Refresh Products',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => productProvider.loadProductsForAdmin(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showProductDialog(context, null),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : CustomScrollView(
              slivers: [
                // Top Metrics & Sync Status Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBanner(productProvider, allProducts.length),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Items',
                                count: allProducts.length.toString(),
                                icon: Icons.inventory_2_rounded,
                                color: Colors.blue.shade700,
                                bg: Colors.blue.shade50,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'In Stock',
                                count: inStockCount.toString(),
                                icon: Icons.check_circle_rounded,
                                color: AppColors.primaryGreen,
                                bg: AppColors.mintGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Out of Stock',
                                count: outOfStockCount.toString(),
                                icon: Icons.warning_rounded,
                                color: Colors.red.shade700,
                                bg: Colors.red.shade50,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search Input
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search product title, brand or category...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Chips Selector
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCategoryChip('All', allProducts.length),
                        ..._categoryOptions.map((cat) {
                          final count = allProducts
                              .where((p) => p.category.toLowerCase() == cat.toLowerCase())
                              .length;
                          return _buildCategoryChip(cat, count);
                        }),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Product List View
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No products match "$_selectedCategory"',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add a new product or seed default products into Firestore.',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _confirmBulkSeed(context, productProvider),
                            icon: const Icon(Icons.cloud_upload_rounded),
                            label: const Text('Seed All Catalog to Firestore'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filtered[index];
                          return _buildProductCard(context, product, productProvider);
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatusBanner(ProductProvider provider, int count) {
    final isSynced = provider.isFirestoreSynced;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSynced ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSynced ? AppColors.primaryGreen.withValues(alpha: 0.3) : Colors.amber.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            size: 20,
            color: isSynced ? AppColors.primaryGreen : Colors.amber.shade900,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSynced ? 'Cloud Firestore Database Active' : 'Offline / Standalone Catalog Mode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSynced ? AppColors.darkGreen : Colors.amber.shade900,
                  ),
                ),
                Text(
                  isSynced
                      ? '$count products connected directly to Firebase.'
                      : 'Tap "Seed to Firestore" to populate your Firebase database with all categories.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isSynced)
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _confirmBulkSeed(context, provider),
              child: const Text(
                'Seed All',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, int count) {
    final isSelected = _selectedCategory.toLowerCase() == category.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$category ($count)'),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.mintGreen,
        checkmarkColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ProductProvider provider,
  ) {
    final inStock = product.stock > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFF9FAFB),
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                cacheWidth: 150,
                cacheHeight: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 28,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PopupMenuButton<String>(
                      tooltip: 'Change Category',
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (newCat) async {
                        await provider.recategorizeProduct(product.id, newCat);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Moved "${product.title}" to $newCat'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => _categoryOptions.map((cat) {
                        final isCurrent = cat.toLowerCase() == product.category.toLowerCase();
                        return PopupMenuItem<String>(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(
                                isCurrent ? Icons.check_circle_rounded : Icons.circle_outlined,
                                size: 16,
                                color: isCurrent ? AppColors.primaryGreen : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrent ? AppColors.primaryGreen : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mintGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 14,
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.unitQuantity,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    // Stock Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: inStock ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inStock ? '${product.stock} in stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: inStock ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.brand,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${AppConstants.currencySymbol}${product.discountedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (product.discountPercentage > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${AppConstants.currencySymbol}${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.discountPercentage.toInt()}% off',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.discountBadge,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Quick Action Buttons
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryGreen),
                      tooltip: 'Edit Product',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _showProductDialog(context, product),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        inStock ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                        size: 24,
                        color: inStock ? AppColors.primaryGreen : Colors.grey,
                      ),
                      tooltip: inStock ? 'Set Out of Stock' : 'Restock',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => provider.toggleStock(product.id),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                      tooltip: 'Delete Product',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _confirmDelete(context, product, provider),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, Product? existing) {
    final isEditing = existing != null;
    final formKey = GlobalKey<FormState>();

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final brandCtrl = TextEditingController(text: existing?.brand ?? 'atBlink Fresh');
    final priceCtrl = TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '50');
    final discountCtrl = TextEditingController(
      text: existing != null ? existing.discountPercentage.toStringAsFixed(0) : '10',
    );
    final stockCtrl = TextEditingController(text: existing?.stock.toString() ?? '50');
    final unitCtrl = TextEditingController(text: existing?.unitQuantity ?? '500 g');
    final etaCtrl = TextEditingController(text: existing?.deliveryEta ?? '10 MINS');
    final descCtrl = TextEditingController(
      text: existing?.description ?? 'Fresh high quality item delivered in 10 minutes.',
    );
    final thumbCtrl = TextEditingController(
      text: existing?.thumbnail ??
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop',
    );

    String selectedCat = existing?.category ?? _categoryOptions.first;
    if (!_categoryOptions.contains(selectedCat)) {
      selectedCat = _categoryOptions.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Product' : 'Add New Product',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Title
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Product Title *',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Please enter a product title' : null,
                      ),
                      const SizedBox(height: 12),

                      // Category & Brand
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCat,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: _categoryOptions.map((cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedCat = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: brandCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Brand',
                                prefixIcon: Icon(Icons.branding_watermark_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price & Discount
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price (₹) *',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                              validator: (val) =>
                                  val == null || double.tryParse(val) == null ? 'Enter price' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: discountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Discount %',
                                prefixIcon: Icon(Icons.percent_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Pack/Unit & Stock
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: unitCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Unit / Weight (e.g. 500 g)',
                                prefixIcon: Icon(Icons.scale_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Stock Count',
                                prefixIcon: Icon(Icons.warehouse_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Thumbnail URL
                      TextFormField(
                        controller: thumbCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Image / Thumbnail URL',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final provider = sheetContext.read<ProductProvider>();
                            final p = Product(
                              id: existing?.id ?? 0,
                              title: titleCtrl.text.trim(),
                              category: selectedCat,
                              brand: brandCtrl.text.trim(),
                              price: double.tryParse(priceCtrl.text) ?? 50.0,
                              discountPercentage: double.tryParse(discountCtrl.text) ?? 0.0,
                              unitQuantity: unitCtrl.text.trim(),
                              stock: int.tryParse(stockCtrl.text) ?? 50,
                              deliveryEta: etaCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              thumbnail: thumbCtrl.text.trim().isNotEmpty
                                  ? thumbCtrl.text.trim()
                                  : 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop',
                              images: [
                                thumbCtrl.text.trim().isNotEmpty
                                    ? thumbCtrl.text.trim()
                                    : 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop',
                              ],
                            );

                            Navigator.pop(sheetContext);

                            if (isEditing) {
                              await provider.updateProduct(p);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product updated successfully in Firestore!'),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              }
                            } else {
                              await provider.addProduct(p);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product added & synced to Firestore!'),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          isEditing ? 'Save Changes' : 'Create Product',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    Product product,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (diagCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to remove "${product.title}" from the Firestore catalog?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(diagCtx);
                await provider.deleteProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed "${product.title}" from database'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmBulkSeed(BuildContext context, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (diagCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.cloud_upload_rounded, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text('Bulk Seed to Firestore'),
            ],
          ),
          content: const Text(
            'This will import all 25+ categorized products (Dairy, Vegetables, Snacks, Drinks, Fruits, Bakery, etc.) into your Firebase Firestore "products" collection in one atomic batch so you don\'t have to add items one by one.\n\nProceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(diagCtx);
                final count = await provider.bulkSeedToFirestore();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully seeded $count products to Firebase Firestore!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              child: const Text('Seed All Catalog'),
            ),
          ],
        );
      },
    );
  }

  void _confirmRestoreDefault(BuildContext context, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (diagCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.restore_page_rounded, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text('Restore Catalog'),
            ],
          ),
          content: const Text(
            'This will reload the full set of 25+ default quick-commerce products (Dairy, Vegetables, Snacks, Drinks, Fruits, Bakery, Personal Care) into the Admin Hub and Firestore.\n\nAny existing catalog will be refreshed. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(diagCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(diagCtx);
                final count = await provider.restoreDefaultCatalog();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restored $count products into Admin and Store!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              },
              child: const Text('Restore Default Items'),
            ),
          ],
        );
      },
    );
  }
}
