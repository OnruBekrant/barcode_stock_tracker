import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _dbHelper.getAllProducts();
      _filteredProducts = List.from(_products);
      if (_searchQuery.isNotEmpty) {
        searchProducts(_searchQuery);
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addProduct(Product product) async {
    final id = await _dbHelper.insertProduct(product);
    await fetchProducts();
    return id;
  }

  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
    await fetchProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    await fetchProducts();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<Product?> checkBarcode(String barcode) async {
    return await _dbHelper.getProductByBarcode(barcode);
  }
}
