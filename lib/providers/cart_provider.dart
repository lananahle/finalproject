import 'package:flutter/foundation.dart';
import '../models/book.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};
  String? _appliedDiscountCode;
  final Map<String, double> _discountCodes = {
    'discount20': 0.20, // 20% discount
  };

  Map<int, CartItem> get items => {..._items};
  String? get appliedDiscountCode => _appliedDiscountCode;

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return _items.values
        .fold(0.0, (sum, item) => sum + (item.book.price * item.quantity));
  }

  double get discount {
    if (_appliedDiscountCode != null &&
        _discountCodes.containsKey(_appliedDiscountCode)) {
      return subtotal * _discountCodes[_appliedDiscountCode]!;
    }
    return 0.0;
  }

  double get totalAmount {
    return subtotal - discount;
  }

  bool applyDiscountCode(String code) {
    if (_discountCodes.containsKey(code.toUpperCase())) {
      _appliedDiscountCode = code.toUpperCase();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeDiscountCode() {
    _appliedDiscountCode = null;
    notifyListeners();
  }

  void addItem(Book book) {
    if (_items.containsKey(book.id)) {
      _items.update(
        book.id,
        (existingItem) => CartItem(
          book: existingItem.book,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        book.id,
        () => CartItem(book: book),
      );
    }
    notifyListeners();
  }

  void removeItem(int bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    _appliedDiscountCode = null;
    notifyListeners();
  }

  void decreaseQuantity(int bookId) {
    if (!_items.containsKey(bookId)) return;

    if (_items[bookId]!.quantity > 1) {
      _items.update(
        bookId,
        (existingItem) => CartItem(
          book: existingItem.book,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(bookId);
    }
    notifyListeners();
  }
}
