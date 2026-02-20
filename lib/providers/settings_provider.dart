import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  int _minStockLimit = 5;
  bool _isStockWarningEnabled = false;

  int get minStockLimit => _minStockLimit;
  bool get isStockWarningEnabled => _isStockWarningEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _minStockLimit = prefs.getInt('minStockLimit') ?? 5;
    _isStockWarningEnabled = prefs.getBool('isStockWarningEnabled') ?? false;
    notifyListeners();
  }

  Future<void> setMinStockLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('minStockLimit', limit);
    _minStockLimit = limit;
    notifyListeners();
  }

  Future<void> setStockWarningEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isStockWarningEnabled', value);
    _isStockWarningEnabled = value;
    notifyListeners();
  }
}
