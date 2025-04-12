// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double wholesalePrice;
  final double retailPrice;
  final int currentStock;
  final int reorderLevel;
  final String unitOfMeasure;
  final bool isActive;
  final String? barcode;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.wholesalePrice,
    required this.retailPrice,
    required this.currentStock,
    required this.reorderLevel,
    required this.unitOfMeasure,
    required this.isActive,
    this.barcode,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'wholesalePrice': wholesalePrice,
      'retailPrice': retailPrice,
      'currentStock': currentStock,
      'reorderLevel': reorderLevel,
      'unitOfMeasure': unitOfMeasure,
      'isActive': isActive,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      wholesalePrice: (map['wholesalePrice'] ?? 0).toDouble(),
      retailPrice: (map['retailPrice'] ?? 0).toDouble(),
      currentStock: map['currentStock'] ?? 0,
      reorderLevel: map['reorderLevel'] ?? 0,
      unitOfMeasure: map['unitOfMeasure'] ?? 'piece',
      isActive: map['isActive'] ?? true,
      barcode: map['barcode'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? wholesalePrice,
    double? retailPrice,
    int? currentStock,
    int? reorderLevel,
    String? unitOfMeasure,
    bool? isActive,
    String? barcode,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      currentStock: currentStock ?? this.currentStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      isActive: isActive ?? this.isActive,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}