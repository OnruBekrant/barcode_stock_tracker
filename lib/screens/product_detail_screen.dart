import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final String? scannedBarcode;

  const ProductDetailScreen({super.key, this.product, this.scannedBarcode});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? _currentId;
  String? _imagePath;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _currentId = widget.product!.id;
      _imagePath = widget.product!.imagePath;
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _descController.text = widget.product!.description ?? '';
    } else {
      _quantityController.text = "0";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _autoSave() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      return;
    }

    final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    final product = Product(
      id: _currentId,
      barcode: widget.product?.barcode ?? widget.scannedBarcode,
      name: _nameController.text.trim(),
      price: price,
      quantity: quantity,
      description: _descController.text.trim(),
      imagePath: _imagePath,
    );

    final productProvider = context.read<ProductProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (_currentId == null) {
      final newId = await productProvider.addProduct(product);
      if (!mounted) return;
      _currentId = newId;
    } else {
      productProvider.updateProduct(product);
    }

    if (settingsProvider.isStockWarningEnabled) {
      final int minLimit = settingsProvider.minStockLimit;
      if (quantity <= minLimit) {
        NotificationService().showStockWarning(product.name, quantity);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamerayla Çek'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
        await _autoSave();
      }
    }
  }

  void _incrementQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 0;
    _quantityController.text = (current + 1).toString();
    _autoSave();
  }

  void _decrementQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 0;
    if (current > 0) {
      _quantityController.text = (current - 1).toString();
      _autoSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String barcodeDisplay =
        widget.product?.barcode ?? widget.scannedBarcode ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentId == null ? 'Yeni Ürün' : 'Ürün Düzenle'),
        actions: [
          if (_currentId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Ürünü Sil'),
                    content: const Text(
                      'Bu ürünü silmek istediğinize emin misiniz?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<ProductProvider>().deleteProduct(
                            _currentId!,
                          );
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to list
                        },
                        child: const Text(
                          'Sil',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imagePath == null
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (barcodeDisplay.isNotEmpty) ...[
              Text(
                'Barkod: $barcodeDisplay',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ürün Adı *'),
              onChanged: (_) => _autoSave(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Fiyat *',
                prefixText: '₺ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => _autoSave(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 32),
                  onPressed: _decrementQuantity,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Miktar',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _autoSave(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 32),
                  onPressed: _incrementQuantity,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged: (_) => _autoSave(),
            ),
          ],
        ),
      ),
    );
  }
}
