import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:xml/xml.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import 'product_manager.dart';

class FileExporter {
  final ProductManager productManager;

  FileExporter(this.productManager);

  // Export all files
  Future<void> exportFiles() async {
    if (productManager.products.isEmpty) {
      throw Exception('No products available to export');
    }
    
    List<File> generatedFiles = [];
    try {
      final directory = await getApplicationDocumentsDirectory();
      //final csvFile = File('${directory.path}/products.csv');
      final pdfFile = File('${directory.path}/products.pdf');
      //final xmlFile = File('${directory.path}/products.xml');
      final jsonFile = File('${directory.path}/products.json');

      // Generate files
      //await _generateCSV(productManager.products, csvFile);
      //generatedFiles.add(csvFile);

      await _generatePDF(productManager.products, pdfFile);
      generatedFiles.add(pdfFile);

      //await _generateXML(productManager.products, xmlFile);
      //generatedFiles.add(xmlFile);

      await _generateJSON(productManager.products, jsonFile);
      generatedFiles.add(jsonFile);

      // Share files
      await _shareFiles(generatedFiles);
    } catch (e) {
      // Clean up any generated files on error
      for (var file in generatedFiles) {
        if (await file.exists()) {
          await file.delete();
        }
      }
      throw Exception('Failed to export files: $e');
    }
  }

  // Generate CSV
  Future<void> _generateCSV(List<Product> products, File file) async {
    try {
      List<List<dynamic>> csvData = [
        ['Product Image', 'Barcode Image', 'Description', 'Price'],
      ];
      for (var product in products) {
        csvData.add([
          product.productImage?.path ?? '',
          product.barcodeImage?.path ?? '',
          product.description,
          product.price,
        ]);
      }
      await file.writeAsString(ListToCsvConverter().convert(csvData));
    } catch (e) {
      rethrow;
    }
  }

  // Generate PDF
  Future<void> _generatePDF(List<Product> products, File file) async {
    try {
      final pdf = pw.Document();
      
      for (var product in products) {
        final productImageBytes = product.productImage != null
            ? await product.productImage!.readAsBytes()
            : null;
        final barcodeImageBytes = product.barcodeImage != null
            ? await product.barcodeImage!.readAsBytes()
            : null;

        pdf.addPage(
          pw.Page(
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (productImageBytes != null)
                  pw.Container(
                    height: 200,
                    child: pw.Image(pw.MemoryImage(productImageBytes)),
                  ),
                pw.SizedBox(height: 10),
                if (barcodeImageBytes != null)
                  pw.Container(
                    height: 100,
                    child: pw.Image(pw.MemoryImage(barcodeImageBytes)),
                  ),
                pw.SizedBox(height: 20),
                pw.Text('Description: ${product.description}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Text('Price: \$${product.price.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Divider(),
              ],
            ),
          ),
        );
      }
      
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      rethrow;
    }
  }

  // Generate XML
  Future<void> _generateXML(List<Product> products, File file) async {
    try {
      final builder = XmlBuilder();
      builder.element('products', nest: () {
        for (var product in products) {
          builder.element('product', nest: () async {
            builder.element('description', nest: product.description);
            builder.element('price', nest: product.price.toString());
            if (product.productImage != null) {
              builder.element('productImage',
                  nest: base64Encode(await product.productImage!.readAsBytes()));
            }
            if (product.barcodeImage != null) {
              builder.element('barcodeImage',
                  nest: base64Encode(await product.barcodeImage!.readAsBytes()));
            }
          });
        }
      });
      await file.writeAsString(builder.buildDocument().toXmlString());
    } catch (e) {
      rethrow;
    }
  }

  // Generate JSON
  Future<void> _generateJSON(List<Product> products, File file) async {
    try {
      // Create list of futures for product data
      final futures = products.map((product) async {
        final productImageBytes = product.productImage != null
            ? base64Encode(await product.productImage!.readAsBytes())
            : null;
        final barcodeImageBytes = product.barcodeImage != null
            ? base64Encode(await product.barcodeImage!.readAsBytes())
            : null;

        return {
          'productImage': productImageBytes,
          'barcodeImage': barcodeImageBytes,
          'description': product.description,
          'price': product.price,
        };
      });

      // Wait for all futures to complete
      final jsonData = await Future.wait(futures);
      
      // Encode the resolved data
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      rethrow;
    }
  }

  // Share files
  Future<void> _shareFiles(List<File> files) async {
    try {
      // Verify files exist and are not empty
      for (var file in files) {
        if (!await file.exists()) {
          throw Exception('Export file not found: ${file.path}');
        }
      }

      final xFiles = files.map((file) => XFile(file.path)).toList();
      
      // Use Share.shareXFiles with explicit subject and text
      await Share.shareXFiles(
        xFiles,
        subject: 'Product Export Files',
        text: 'Exported product data in CSV, PDF, XML, and JSON formats',
      );
    } catch (e) {
      throw Exception('Failed to share files: $e');
    }
  }
}