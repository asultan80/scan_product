import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../utils/error_handler.dart';
import 'package:camera/camera.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onAddProduct;
  final Product? initialProduct;

  const AddProductScreen({
    super.key,
    required this.onAddProduct,
    this.initialProduct,
  });

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? _errorMessage;
  File? productImage;
  File? barcodeImage;
  String description = '';
  double price = 0.0;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      productImage = widget.initialProduct!.productImage;
      barcodeImage = widget.initialProduct!.barcodeImage;
      description = widget.initialProduct!.description;
      price = widget.initialProduct!.price;
      _descriptionController.text = description;
      _priceController.text = price.toString();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  final _picker = ImagePicker();

  Future<void> _pickImage(bool isCamera, Function(File) callback) async {
    try {
      ImageSource source = isCamera ? ImageSource.camera : ImageSource.gallery;
      
      // If camera is requested but not available, show dialog to use gallery
      if (isCamera) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          final useGallery = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Camera Not Available'),
              content: const Text('Would you like to choose from gallery instead?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Use Gallery'),
                ),
              ],
            ),
          );
          
          if (useGallery != true) return;
          source = ImageSource.gallery;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (pickedFile == null) {
        setState(() {
          _errorMessage = ErrorHandler.validationMessages['no_image_selected'];
        });
        return;
      }

      final File imageFile = File(pickedFile.path);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      setState(() {
        callback(imageFile);
        _errorMessage = null;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.handleProductError('image_pick', e);
      });
    }
  }

  Future<void> _saveProduct() async {
    try {
      if (!(_formKey.currentState?.validate() ?? false)) {
        throw Exception(ErrorHandler.validationMessages['form_invalid']);
      }

      if (productImage == null || barcodeImage == null) {
        throw Exception(ErrorHandler.validationMessages['missing_images']);
      }

      // Verify files exist before saving
      if (!await productImage!.exists() || !await barcodeImage!.exists()) {
        throw Exception(ErrorHandler.validationMessages['image_not_found']);
      }

      widget.onAddProduct(Product(
        productImage: productImage!,
        barcodeImage: barcodeImage!,
        description: description.trim(),
        price: price,
      ));
      
      Navigator.pop(context);
    } on Exception catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.handleProductError('save', e);
      });
    }
  }

  Future<void> _showImageSourceDialog(Function(File) onImagePicked) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(true, onImagePicked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(false, onImagePicked);
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
        title: Text(widget.initialProduct != null ? 'Edit Product' : 'Add Product')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              
              if (productImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.file(productImage!, height: 100),
                ),
                
              ElevatedButton(
                onPressed: () => _showImageSourceDialog((file) => productImage = file),
                child: const Text('Capture Product Image'),
              ),
              
              if (barcodeImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.file(barcodeImage!, height: 100),
                ),
                
              ElevatedButton(
                onPressed: () => _showImageSourceDialog((file) => barcodeImage = file),
                child: const Text('Capture Barcode Image'),
              ),
              
              TextFormField(
                controller: _descriptionController,
                onChanged: (value) => description = value,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ErrorHandler.validationMessages['required_field'];
                  }
                  return null;
                },
              ),
              
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ErrorHandler.validationMessages['required_field'];
                  }
                  if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                    return ErrorHandler.validationMessages['invalid_price'];
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}