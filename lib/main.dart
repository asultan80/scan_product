import 'package:flutter/material.dart';
import 'package:scan_product/screens/product_list_screen.dart';

void main() {
  runApp(MaterialApp(
    title: 'Product Management',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: ProductListScreen(),
  ));
}