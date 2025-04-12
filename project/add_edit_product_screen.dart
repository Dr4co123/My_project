// lib/screens/add_edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/model/product_model.dart';
import 'package:myapp/services/product_service.dart';
import 'package:uuid/uuid.dart';

import 'package:provider/provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final bool isEditing;
  
  const AddEditProductScreen({Key? key, this.isEditing = false}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _retailPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  final _barcodeController = TextEditingController();
  bool _isActive = true;
  
  late Product _product;
  bool _isLoading = true;
  final _uuid = Uuid();
  
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }
  
  Future<void> _loadProduct() async {
    if (!widget.isEditing) {
      // New product, set defaults
      _currentStockController.text = '0';
      _reorderLevelController.text = '5';
      _unitOfMeasureController.text = 'piece';
      _isLoading = false;
      return;
    }
    
    // Editing existing product - need to wait for build to complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      final productService = Provider.of<ProductService>(context, listen: false);
      final product = await productService.getProduct(productId);
      
      if (product != null) {
        _product = product;
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _categoryController.text = product.category;
        _wholesalePriceController.text = product.wholesalePrice.toString();
        _retailPriceController.text = product.retailPrice.toString();
        _currentStockController.text = product.currentStock.toString();
        _reorderLevelController.text = product.reorderLevel.toString();
        _reorderLevelController.text = product.reorderLevel.toString();
        _unitOfMeasureController.text = product.unitOfMeasure;
        if (product.barcode != null) {
          _barcodeController.text = product.barcode!;
        }
        _isActive = product.isActive;
      }
      
      setState(() {
        _isLoading = false;
      });
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _wholesalePriceController.dispose();
    _retailPriceController.dispose();
    _currentStockController.dispose();
    _reorderLevelController.dispose();
    _unitOfMeasureController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final productService = Provider.of<ProductService>(context, listen: false);
  
    
    final newProduct = Product(
      id: widget.isEditing ? _product.id : _uuid.v4(),
      name: _nameController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      wholesalePrice: double.parse(_wholesalePriceController.text),
      retailPrice: double.parse(_retailPriceController.text),
      currentStock: int.parse(_currentStockController.text),
      reorderLevel: int.parse(_reorderLevelController.text),
      unitOfMeasure: _unitOfMeasureController.text,
      isActive: _isActive,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
      imageUrl: null,
      createdAt: widget.isEditing ? _product.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    if (widget.isEditing) {
      await productService.updateProduct(newProduct);
    } else {
      await productService.addProduct(newProduct);
    }
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEditing ? 'Product updated!' : 'Product added!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
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
                    // Basic Information
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Category
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Pricing
                    const Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Wholesale Price
                    TextFormField(
                      controller: _wholesalePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Wholesale Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter wholesale price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Retail Price
                    TextFormField(
                      controller: _retailPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Retail Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter retail price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Inventory
                    const Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Current Stock
                    TextFormField(
                      controller: _currentStockController,
                      decoration: const InputDecoration(
                        labelText: 'Current Stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter current stock';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Reorder Level
                    TextFormField(
                      controller: _reorderLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level',
                        border: OutlineInputBorder(),
                        helperText: 'When stock falls below this level, it will be marked as low',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter reorder level';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Unit of Measure
                    TextFormField(
                      controller: _unitOfMeasureController,
                      decoration: const InputDecoration(
                        labelText: 'Unit of Measure',
                        border: OutlineInputBorder(),
                        helperText: 'e.g., piece, kg, liter',
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Additional Information
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Barcode
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Active Status
                    SwitchListTile(
                      title: const Text('Product is active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: Text(
                          widget.isEditing ? 'Update Product' : 'Add Product',
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