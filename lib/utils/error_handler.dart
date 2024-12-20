import 'dart:io';
import 'package:flutter/services.dart';

class ErrorHandler {
  // Generic error messages
  static const String imagePickError = 'Failed to pick image';
  static const String savingError = 'Failed to save product';
  static const String networkError = 'Network connection error';
  static const String validationError = 'Validation failed';

  // Handle different types of errors and return user-friendly messages
  static String handleError(dynamic error) {
    if (error is Exception) {
      return _handleException(error);
    } else {
      return error?.toString() ?? 'An unknown error occurred';
    }
  }

  static String _handleException(Exception exception) {
    // Handle specific exceptions
    switch (exception.runtimeType) {
      case FormatException _:
        return 'Invalid format';
      case TypeError _:
        return 'Type conversion error';
      case StateError _:
        return 'Application state error';
      case FileSystemException _:
        return 'File system error: Unable to access image';
      case PlatformException _:
        return 'Platform error: Unable to access camera or gallery';
      default:
        final message = exception.toString().replaceAll('Exception: ', '');
        return message;
    }
  }

  // Specific error handlers for product-related operations
  static String handleProductError(String operation, dynamic error) {
    switch (operation) {
      case 'save':
        return '$savingError: ${handleError(error)}';
      case 'image_pick':
        return '$imagePickError: ${handleError(error)}';
      default:
        return handleError(error);
    }
  }

  // Validation error messages
  static const Map<String, String> validationMessages = {
    'required_field': 'This field is required',
    'invalid_price': 'Please enter a valid price greater than 0',
    'missing_images': 'Please capture both product and barcode images',
    'invalid_description': 'Description cannot be empty',
    'no_image_selected': 'No image was selected',
    'image_not_found': 'Selected image file not found',
    'form_invalid': 'Please correct the errors in the form',
    'no_products': 'No products available to export',
  };
}
