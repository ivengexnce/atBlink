class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  final String unitQuantity; // e.g., "500 g", "1 L", "250 g", "1 Pack"
  final String deliveryEta; // e.g., "8 mins", "10 mins"

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountPercentage = 0.0,
    this.rating = 4.5,
    this.stock = 50,
    this.brand = 'atBlink Fresh',
    required this.category,
    required this.thumbnail,
    this.images = const [],
    this.unitQuantity = '1 Pack',
    this.deliveryEta = '10 MINS',
  });

  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    return price * (1 - (discountPercentage / 100));
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] != null) {
      imgList = List<String>.from(json['images']);
    }

    // Infer realistic quick commerce unit quantity from title or id
    String inferredUnit = '1 Pack';
    String titleLower = (json['title'] ?? '').toString().toLowerCase();
    if (titleLower.contains('milk') || titleLower.contains('juice') || titleLower.contains('oil') || titleLower.contains('water')) {
      inferredUnit = '1 Litre';
    } else if (titleLower.contains('apple') || titleLower.contains('potato') || titleLower.contains('tomato') || titleLower.contains('fruit') || titleLower.contains('onion')) {
      inferredUnit = '500 g';
    } else if (titleLower.contains('bread') || titleLower.contains('biscuit') || titleLower.contains('chips')) {
      inferredUnit = '200 g';
    } else if (titleLower.contains('butter') || titleLower.contains('cheese')) {
      inferredUnit = '100 g';
    }

    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Fresh Item',
      description: json['description'] ?? 'High quality item delivered in 10 minutes.',
      price: (json['price'] as num?)?.toDouble() ?? 4.99,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 10.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      stock: json['stock'] is int ? json['stock'] : 30,
      brand: json['brand'] ?? 'atBlink Express',
      category: json['category'] ?? 'Groceries',
      thumbnail: json['thumbnail'] ?? (imgList.isNotEmpty ? imgList.first : 'https://via.placeholder.com/150'),
      images: imgList.isNotEmpty ? imgList : [json['thumbnail'] ?? 'https://via.placeholder.com/150'],
      unitQuantity: json['unitQuantity'] ?? inferredUnit,
      deliveryEta: json['deliveryEta'] ?? '10 MINS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
      'unitQuantity': unitQuantity,
      'deliveryEta': deliveryEta,
    };
  }
}
