// lib/models/stock_transaction.dart
class StockTransaction {
  final String id;
  final String productId;
  final int quantity;
  final String type; // 'addition', 'reduction'
  final String reason;
  final DateTime timestamp;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.type,
    required this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'type': type,
      'reason': reason,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory StockTransaction.fromMap(Map<String, dynamic> map) {
    return StockTransaction(
      id: map['id'],
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 0,
      type: map['type'] ?? '',
      reason: map['reason'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}