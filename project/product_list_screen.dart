// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/model/product_model.dart';
import 'package:myapp/utils/formatter.dart';
import 'package:provider/provider.dart';

import '../services/product_service.dart';


class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: Provider.of<ProductService>(context, listen: false).getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data ?? [];
          
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No products yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/products/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isLowStock = product.currentStock <= product.reorderLevel;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    'Stock: ${product.currentStock} ${product.unitOfMeasure}${isLowStock ? ' (Low stock)' : ''}',
                    style: TextStyle(
                      color: isLowStock ? Colors.red : null,
                      fontWeight: isLowStock ? FontWeight.bold : null,
                    ),
                  ),
                  trailing: Text(
                    formatCurrency(product.retailPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/products/detail',
                    arguments: product.id,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/products/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}