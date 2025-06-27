import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_card_app/cart_model.dart';
import 'package:shopping_card_app/db_helper.dart';

class CartProvider with ChangeNotifier {
  DBHelper db = DBHelper();

  int _counter = 0;
  double _totalPrice = 0.0;
  late Future<List<Cart>> _cart;

  int get counter => _counter;
  double get totalPrice => _totalPrice;
  Future<List<Cart>> get cart => _cart;

  CartProvider() {
    loadPreferences(); // ✅ Public method for loading prefs on init
  }

  /// ✅ PUBLIC method to allow calling from UI (`loadPreferences()` instead of `_loadPreferences`)
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('cart_item') ?? 0;
    _totalPrice = prefs.getDouble('total_price') ?? 0.0;
    notifyListeners();
  }

  /// PRIVATE method to save to SharedPreferences
  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cart_item', _counter);
    await prefs.setDouble('total_price', _totalPrice);
  }

  /// Get cart data from DB
  Future<List<Cart>> getData() async {
    _cart = db.getCartList();
    return _cart;
  }

  /// Add price
  void addTotalPrice(double productPrice) {
    _totalPrice += productPrice;
    _savePreferences();
    notifyListeners();
  }

  /// Subtract price
  void removeTotalPrice(double productPrice) {
    _totalPrice -= productPrice;
    _savePreferences();
    notifyListeners();
  }

  /// Add item
  void addCounter() {
    _counter++;
    _savePreferences();
    notifyListeners();
  }

  /// Remove item
  void removeCounter() {
    if (_counter > 0) {
      _counter--;
      _savePreferences();
      notifyListeners();
    }
  }

  /// Optional: Reset cart completely
  void resetCart() {
    _counter = 0;
    _totalPrice = 0.0;
    _savePreferences();
    notifyListeners();
  }
}
