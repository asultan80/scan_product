import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: product.productImage != null
          ? Image.file(product.productImage!, width: 50, height: 50)
          : const Icon(Icons.image),
      title: Text(product.description),
      subtitle: Text('\$${product.price}'),
      onTap: onTap,
    );
  }
}