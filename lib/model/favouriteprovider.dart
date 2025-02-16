import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wx_styleloft_project_flutter/model/clothing.dart';
// import 'package:wx_styleloft_project_flutter/services/httpservice.dart'; // Assuming HttpService exists
import 'package:firebase_auth/firebase_auth.dart';


class FavoriteProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Set<String>> _favorites = {};

  Future<void> loadFavorites(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        _favorites[userId] = (data['favorites'] as Map<String, dynamic>?)?.keys.toSet() ?? {};
      } else {
        _favorites[userId] = {};
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  bool isFavorite(String userId, String productId) {
    return _favorites[userId]?.contains(productId) ?? false;
  }

  Future<void> addToFavorites(String userId, Clothing product) async {
    try {
      // Add the product to the user's favorites in Firebase
      await _firestore.collection('users').doc(userId).update({
        'favorites.${product.id}': true,
      });

      // Update local state
      _favorites[userId]?.add(product.id.toString());
      notifyListeners();
    } catch (e) {
      print("Error adding to favorites: $e");
    }
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      // Remove the product from the user's favorites in Firebase
      await _firestore.collection('users').doc(userId).update({
        'favorites.$productId': FieldValue.delete(),
      });

      // Update local state
      _favorites[userId]?.remove(productId);
      notifyListeners();
    } catch (e) {
      print("Error removing from favorites: $e");
    }
  }
}
