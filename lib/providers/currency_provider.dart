import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  bool _isLBP = false;
  double _lbpRate = 90000;
  static const String CURRENCY_KEY = 'isLBP';

  bool get isLBP => _isLBP;
  double get lbpRate => _lbpRate;

  CurrencyProvider() {
    _loadCurrencyPreference();
  }

  Future<void> _loadCurrencyPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLBP = prefs.getBool(CURRENCY_KEY) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading currency preference: $e');
      // Fallback to default USD
      _isLBP = false;
      notifyListeners();
    }
  }

  Future<void> toggleCurrency() async {
    try {
      _isLBP = !_isLBP;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(CURRENCY_KEY, _isLBP);
      notifyListeners();
    } catch (e) {
      print('Error saving currency preference: $e');
      // Revert the change if saving fails
      _isLBP = !_isLBP;
      notifyListeners();
    }
  }

  String formatPrice(double priceUSD) {
    if (_isLBP) {
      final priceLBP = priceUSD * _lbpRate;
      return '${priceLBP.toStringAsFixed(0)} LBP';
    }
    return '\$${priceUSD.toStringAsFixed(2)}';
  }
}
