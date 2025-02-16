import 'package:flutter/material.dart';

class CartItem {
  final int cartId;  // Unique cart ID
  final String userId; // User reference
  final int productId; // Unique product reference
  int quantity;
  String producttitle;
  String size;
  String imgPath;
  String price; // Price from API

  CartItem({
    required this.cartId,
    required this.producttitle,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.size,
    required this.imgPath,
    required this.price,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, Map<int, CartItem>> _userCarts = {}; // Store cart per user

  Map<int, CartItem> getCart(String userId) {
    return _userCarts[userId] ?? {};
  }

  int getCartCount(String userId) {
    return getCart(userId).length;
  }

  int getTotalItems(String userId) {
    return getCart(userId).values.fold(0, (sum, item) => sum + item.quantity); // Total quantity of items
  }

  double getTotalPrice(String userId) {
    return getCart(userId).values.fold(0.0, (total, item) => total + (double.parse(item.price) * item.quantity));
  }

  void addToCart({
    required int cartId,
    required String userId,
    required int productId,
    required String size,
    required String imgPath,
    required String producttitle,
    required String price,
    required int quantity,
  }) {
    _userCarts.putIfAbsent(userId, () => {}); // Ensure user cart exists

    if (_userCarts[userId]!.containsKey(cartId)) {
      _userCarts[userId]![cartId]!.quantity += quantity; // Increase quantity
    } else {
      _userCarts[userId]![cartId] = CartItem(
        cartId: cartId,
        userId: userId,
        productId: productId,
        producttitle: producttitle,
        quantity: quantity,
        size: size,
        imgPath: imgPath,
        price: price,
      );
    }
    notifyListeners();
  }

  void removeFromCart(String userId, int cartId) {
    if (_userCarts.containsKey(userId)) {
      if (_userCarts[userId]!.containsKey(cartId)) {
        if (_userCarts[userId]![cartId]!.quantity > 1) {
          _userCarts[userId]![cartId]!.quantity -= 1;
        } else {
          _userCarts[userId]!.remove(cartId);
        }
        notifyListeners();
      }
    }
  }

  void clearCart(String userId) {
    _userCarts.remove(userId);
    notifyListeners();
  }
}
