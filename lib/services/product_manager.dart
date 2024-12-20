import 'package:scan_product/models/product.dart';

class ProductManager {
  List<Product> products = [];

  static final ProductManager _instance = ProductManager._internal();
  
  factory ProductManager() {
    return _instance;
  }
  
  ProductManager._internal();

  // Add product to the list
  void addProduct(Product product) {
    products.add(product);
  }

  // Edit a product by index
  void editProduct(int index, Product updatedProduct) {
    if (index >= 0 && index < products.length) {
      products[index] = updatedProduct;
    }
  }

  // Delete product by index
  void deleteProduct(int index) {
    if (index >= 0 && index < products.length) {
      products.removeAt(index);
    }
  }

  // Clear all products
  void clearAllProducts() {
    products.clear();
  }
}