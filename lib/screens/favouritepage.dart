import 'package:flutter/material.dart';
import 'package:wx_styleloft_project_flutter/model/clothing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wx_styleloft_project_flutter/services/httpservice.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'productdetail.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Clothing>? favoriteProducts;
  bool isLoading = true;
  Set<String> favoriteProductIds = <String>{};
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "user_123"; // Replace with actual user ID from Firebase

  @override
  void initState() {
    super.initState();
    fetchFavoriteProducts();
  }

  // Fetch user's favorite products from Firebase
  void fetchFavoriteProducts() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final favoriteDocs = await userDoc.collection('favorites').get();

    Set<String> loadedFavorites = {};
    for (var doc in favoriteDocs.docs) {
      loadedFavorites.add(doc['productId'].toString());
    }

    // Fetch all favorite products using their IDs
    if (mounted) {
      setState(() {
        favoriteProductIds = loadedFavorites;
        isLoading = false;
      });

      List<Clothing> favorites = [];
      for (String productId in favoriteProductIds) {
        Clothing? product = await HttpService.getProductById(productId);
        if (product != null) {
          favorites.add(product);
        }
      }

      if (mounted) {
        setState(() {
          favoriteProducts = favorites;
        });
      }
    }
  }

  // Toggle favorite status for a product
  Future<void> toggleFavorite(String productId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final favoriteDoc = userDoc.collection('favorites').doc(productId);
    final favoriteSnapshot = await favoriteDoc.get();

    if (favoriteSnapshot.exists) {
      // Remove the product from favorites
      await favoriteDoc.delete();
      setState(() {
        favoriteProductIds.remove(productId);
        favoriteProducts?.removeWhere((product) => product.id == productId);
      });
    } else {
      // Add the product to favorites
      final product = await HttpService.getProductById(productId);
      if (product != null) {
        await favoriteDoc.set({
          'productId': product.id,
          'title': product.title,
          'price': product.price,
          'image': product.image.isNotEmpty ? product.image[0] : '',
        });
        setState(() {
          favoriteProductIds.add(productId);
          favoriteProducts?.add(product);
        });
      }
    }

    // Refresh the favorite products list after toggling
    fetchFavoriteProducts(); // Reload the favorite list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteProducts == null || favoriteProducts!.isEmpty
              ?  const Center(child: Text("No favorite products"))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MasonryGridView.builder(
                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    itemCount: favoriteProducts!.length,
                    itemBuilder: (context, index) {
                      final product = favoriteProducts![index];
                      return _buildProductCard(product);
                    },
                  ),
                ),
    );
  }

  // Build individual product card
  Widget _buildProductCard(Clothing product) {
    bool isFavorite = favoriteProductIds.contains(product.id.toString());

    return GestureDetector(
      onTap: () {
        // Navigate to product detail page (optional)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product,
            sizes: const ["S", "M", "L", "XL"],),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Hero(
                    tag: 'hero_${product.id}',
                    child: Image.network(
                      product.image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[300]);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      toggleFavorite(product.id.toString());
                    },
                  ),
                ),
              ],
            ),
            // Padding for title and price inside card
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with ellipsis if text is long
                  Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Price display
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  // Favorite button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
