// lib/screens/stock_adjustment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/model/product_model.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/stock_transaction_services.dart';
import 'package:provider/provider.dart';


class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({Key? key}) : super(key: key);

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  
  late Product _product;
  String _adjustmentType = 'addition';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }
  
  Future<void> _loadProduct() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      final productService = Provider.of<ProductService>(context, listen: false);
      final product = await productService.getProduct(productId);
      
      if (product != null) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _saveAdjustment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final stockService = Provider.of<StockTransactionService>(context, listen: false);
    
    // If this is a reduction, make sure we have enough stock
    if (_adjustmentType == 'reduction') {
      final quantity = int.parse(_quantityController.text);
      if (quantity > _product.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough stock available!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    try {
      await stockService.addTransaction(
        _product.id,
        int.parse(_quantityController.text),
        _adjustmentType,
        _reasonController.text,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating stock: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Stock'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Info
                    Text(
                      _product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Current Stock: ${_product.currentStock} ${_product.unitOfMeasure}'),
                    const SizedBox(height: 24),
                    
                    // Adjustment Type
                    const Text(
                      'Adjustment Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Add Stock'),
                            value: 'addition',
                            groupValue: _adjustmentType,
                            onChanged: (value) {
                              setState(() {
                                _adjustmentType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Remove Stock'),
                            value: 'reduction',
                            groupValue: _adjustmentType,
                            onChanged: (value) {
                              setState(() {
                                _adjustmentType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: const OutlineInputBorder(),
                        suffixText: _product.unitOfMeasure,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Reason
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Adjustment',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., New purchase, Sales, Inventory count, Damage',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAdjustment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: Text(
                          _adjustmentType == 'addition' ? 'Add Stock' : 'Remove Stock',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}