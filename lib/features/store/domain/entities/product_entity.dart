import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String description;
  final int stockCount;
  final double rating;
  final bool isFeatured;
  final List<String> variants;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.description,
    this.stockCount = 10,
    this.rating = 4.8,
    this.isFeatured = false,
    this.variants = const ['Standard', 'Deluxe Edition', 'Collector Tier'],
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['product_id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['original_price'] as num?)?.toDouble(),
      imageUrl: map['image_url'] ?? '',
      description: map['description'] ?? '',
      stockCount: map['stock_count'] as int? ?? 10,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': id,
      'name': name,
      'category': category,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'description': description,
      'stock_count': stockCount,
      'rating': rating,
      'is_featured': isFeatured ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        price,
        originalPrice,
        imageUrl,
        description,
        stockCount,
        rating,
        isFeatured,
      ];
}
