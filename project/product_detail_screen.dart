// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/model/product_model.dart';
import 'package:myapp/utils/formatter.dart';
import 'package:provider/provider.dart';

import '../services/product_service.dart';


class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final productService = Provider.of<ProductService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context, 
              '/products/edit',
              arguments: productId,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Product?>(
        future: productService.getProduct(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final product = snapshot.data;
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          
          final isLowStock = product.currentStock <= product.reorderLevel;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and basic info
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.description),
                const SizedBox(height: 16),
                
                // Pricing card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pricing',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Wholesale Price'),
                                  Text(
                                    formatCurrency(product.wholesalePrice),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Retail Price'),
                                  Text(
                                    formatCurrency(product.retailPrice),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stock card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Stock Information',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pushNamed(
                                context, 
                                '/stock/history',
                                arguments: productId,
                              ),
                              child: const Text(
                                'View History',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current Stock'),
                                  Text(
                                    '${product.currentStock} ${product.unitOfMeasure}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isLowStock ? Colors.red : null,
                                    ),
                                  ),
                                  if (isLowStock)
                                    const Text(
                                      'Low stock!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Reorder Level'),
                                  Text(
                                    '${product.reorderLevel} ${product.unitOfMeasure}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context, 
                            '/stock/adjust',
                            arguments: productId,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Adjust Stock'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Additional info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Category', product.category),
                        _buildInfoRow('Unit of Measure', product.unitOfMeasure),
                        if (product.barcode != null)
                          _buildInfoRow('Barcode', product.barcode!),
                        _buildInfoRow('Status', product.isActive ? 'Active' : 'Inactive'),
                        _buildInfoRow('Created', formatDate(product.createdAt)),
                        _buildInfoRow('Last Updated', formatDate(product.updatedAt)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}