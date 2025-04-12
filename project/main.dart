// lib/main.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/product_list_screem.dart';
import 'package:myapp/services/stock_transaction_services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_product_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/stock_adjustment_screen.dart';
import 'screens/stock_history_screen.dart';
import 'services/product_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => StockTransactionService()),
      ],
      child: MaterialApp(
        title: 'Biz Inventory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/products': (context) => const ProductListScreen(),
          '/products/add': (context) => const AddEditProductScreen(),
          '/products/edit': (context) => const AddEditProductScreen(isEditing: true),
          '/products/detail': (context) => const ProductDetailScreen(),
          '/stock/adjust': (context) => const StockAdjustmentScreen(),
          '/stock/history': (context) => const StockHistoryScreen(),
        },
      ),
    );
  }
}



