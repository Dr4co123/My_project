// lib/services/product_service.dart
import 'dart:convert';
import 'package:myapp/model/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final Map<String, Product> _products = {};
  final _uuid = Uuid();

  // Add a new product
  Future<Product> addProduct(Product product) async {
    final newProduct = product.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _products[newProduct.id] = newProduct;
    await _saveProducts();
    return newProduct;
  }

  // Update an existing product
  Future<Product> updateProduct(Product product) async {
    final updatedProduct = product.copyWith(
      updatedAt: DateTime.now(),
    );
    
    _products[updatedProduct.id] = updatedProduct;
    await _saveProducts();
    return updatedProduct;
  }

  // Get a single product by ID
  Future<Product?> getProduct(String id) async {
    await _loadProducts(); // Ensure products are loaded
    return _products[id];
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    await _loadProducts(); // Ensure products are loaded
    return _products.values.toList();
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    _products.remove(id);
    await _saveProducts();
  }

  // Save products to persistent storage
  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = _products.values.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList('products', productsJson);
  }

  // Load products from persistent storage
  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getStringList('products') ?? [];
    
    if (productsJson.isEmpty) return;
    
    for (final json in productsJson) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final product = Product.fromMap(map);
      _products[product.id] = product;
    }
  }
}