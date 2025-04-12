// lib/services/stock_transaction_service.dart
import 'dart:convert';
import 'package:myapp/model/product_model.dart';
import 'package:myapp/model/stock_transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'product_service.dart';

class StockTransactionService {
  static final StockTransactionService _instance = StockTransactionService._internal();
  factory StockTransactionService() => _instance;
  StockTransactionService._internal();
  
  final _productService = ProductService();
  final List<StockTransaction> _transactions = [];
  final _uuid = Uuid();

  Future<Product> addTransaction(String productId, int quantity, String type, String reason) async {
    // Get the product
    final product = await _productService.getProduct(productId);
    if (product == null) {
      throw Exception('Product not found');
    }
    
    // Create transaction
    final transaction = StockTransaction(
      id: _uuid.v4(),
      productId: productId,
      quantity: quantity,
      type: type,
      reason: reason,
      timestamp: DateTime.now(),
    );
    
    // Add the transaction
    _transactions.add(transaction);
    await _saveTransactions();
    
    // Update the product stock
    int newStock = product.currentStock;
    if (type == 'addition') {
      newStock += quantity;
    } else if (type == 'reduction') {
      newStock -= quantity;
    }
    
    // Update product
    final updatedProduct = product.copyWith(
      currentStock: newStock,
      updatedAt: DateTime.now(),
    );
    
    return await _productService.updateProduct(updatedProduct);
  }

  Future<List<StockTransaction>> getTransactionsForProduct(String productId) async {
    await _loadTransactions();
    return _transactions
        .where((txn) => txn.productId == productId)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  Future<List<StockTransaction>> getAllTransactions() async {
    await _loadTransactions();
    return _transactions.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  // Save transactions to persistent storage
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txnJson = _transactions.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList('stock_transactions', txnJson);
  }

  // Load transactions from persistent storage
  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txnJson = prefs.getStringList('stock_transactions') ?? [];
    
    if (txnJson.isEmpty) return;
    
    _transactions.clear();
    for (final json in txnJson) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final transaction = StockTransaction.fromMap(map);
      _transactions.add(transaction);
    }
  }
}