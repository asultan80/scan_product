import 'package:flutter/material.dart';
import 'package:scan_product/services/product_manager.dart';
import 'package:scan_product/utils/error_handler.dart';
import '../models/product.dart';
import '../services/file_exporter.dart';
import '../widgets/product_tile.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductManager _productManager = ProductManager();
  late final FileExporter _fileExporter;

  List<Product> get _products => _productManager.products;

  @override
  void initState() {
    super.initState();
    _fileExporter = FileExporter(_productManager);
  }

  void _addProduct(Product product) {
    setState(() {
      _productManager.products.add(product);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _productManager.products.removeAt(index);
    });
  }

  void _editProduct(int index, Product product) {
    setState(() {
      _productManager.products[index] = product;
    });
  }

  void _exportData() async {
    try {
      await _fileExporter.exportFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Products exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.handleError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProductOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen(
                        onAddProduct: (product) => _editProduct(index, product),
                        initialProduct: _products[index],
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProduct(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _exportData,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) => ProductTile(
          product: _products[index],
          onTap: () => _showProductOptions(context, index),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProductScreen(onAddProduct: _addProduct)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}