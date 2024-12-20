import 'package:flutter/material.dart';
import 'package:scan_product/services/product_manager.dart';
import 'package:scan_product/services/file_exporter.dart';

import '../models/product.dart';

class ProductManagementScreen extends StatelessWidget {
  final ProductManager productManager = ProductManager();
  final FileExporter fileExporter;

  ProductManagementScreen({super.key}) : fileExporter = FileExporter(ProductManager());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Management")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await fileExporter.exportFiles();
            },
            child: Text("Export Files"),
          ),
          ElevatedButton(
            onPressed: () {
              // Example to edit a product
              Product updatedProduct = Product(
                description: "Updated Product",
                price: 19.99,
                productImage: null, // Update with actual image if needed
                barcodeImage: null, // Update with actual image if needed
              );
              productManager.editProduct(0, updatedProduct);
            },
            child: Text("Edit First Product"),
          ),
          ElevatedButton(
            onPressed: () {
              // Example to delete a product
              productManager.deleteProduct(0);
            },
            child: Text("Delete First Product"),
          ),
          ElevatedButton(
            onPressed: () {
              // Example to clear all products
              productManager.clearAllProducts();
            },
            child: Text("Clear All Products"),
          ),
        ],
      ),
    );
  }
}