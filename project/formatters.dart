// lib/utils/formatters.dart
import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  return NumberFormat.currency(symbol: '\$').format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('MMM d, yyyy h:mm a').format(date);
}