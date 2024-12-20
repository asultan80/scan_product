import 'dart:convert';
import 'dart:io';

class Product {
  String description;
  double price;
  File? productImage;
  File? barcodeImage;

  Product({
    required this.description,
    required this.price,
    this.productImage,
    this.barcodeImage,
  });

  // A method to return product details as a map (useful for exporting to JSON, XML, etc.)
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'price': price,
      'productImage': productImage?.path,
      'barcodeImage': barcodeImage?.path,
    };
  }

  // A method to return the base64 encoded images (if available)
  Map<String, String?> encodeImages() {
    return {
      'productImage': productImage != null
          ? base64Encode(productImage!.readAsBytesSync())
          : null,
      'barcodeImage': barcodeImage != null
          ? base64Encode(barcodeImage!.readAsBytesSync())
          : null,
    };
  }
}