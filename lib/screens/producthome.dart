import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:wx_styleloft_project_flutter/model/clothing.dart';
import 'package:wx_styleloft_project_flutter/services/httpservice.dart';
import 'package:wx_styleloft_project_flutter/model/favouriteprovider.dart';
import 'productdetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Clothing>? products;
  String searchQuery = '';

  Set<Category> selectedCategories = {};

  bool isLoading = true;
  String selectedPriceFilter = '';
  Set<String> favoriteProductIds = <String>{}; // Track favorite product IDs
  late String userId; // Store the user ID dynamically

  final List<Category> categories = [
    Category.ALL,
    Category.ELECTRONICS,
    Category.JEWELERY,
    Category.MEN_S_CLOTHING,
    Category.WOMEN_S_CLOTHING,
  ];

  @override
  void initState() {
    super.initState();
    _getUserData(); // Call to fetch user data on init
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid; // Dynamically fetch user ID
      await fetchFavorites(userId); // Fetch favorite products for the user
      fetchProducts(); // Fetch the products based on the search query and filters
    }
  }

  void fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 5), () async {
      List<Clothing>? fetchedProducts = await HttpService.getClothing(searchQuery);

       List<Clothing> validProducts = [];
      for (var product in fetchedProducts ?? []) {
        bool isValidImage = product.image.isNotEmpty && Uri.tryParse(product.image)?.hasAbsolutePath == true;
        bool isValidCategory = selectedCategories.isEmpty || selectedCategories.contains(product.category) || selectedCategories.contains(Category.ALL);

        if (isValidImage && isValidCategory) {
          validProducts.add(product);
        }
      }

      if (selectedPriceFilter == 'asc') {
        validProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (selectedPriceFilter == 'desc') {
        validProducts.sort((a, b) => b.price.compareTo(a.price));
      }

      setState(() {
        products = validProducts.isNotEmpty ? validProducts : null;
        isLoading = false;
      });
    });
  }

  Future<void> fetchFavorites(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final favoriteDocs = await userDoc.collection('favorites').get();

    Set<String> loadedFavorites = {};
    for (var doc in favoriteDocs.docs) {
      loadedFavorites.add(doc['productId'].toString());
    }

    setState(() {
      favoriteProductIds = loadedFavorites;
    });
  }

  void toggleCategory(Category category) {
    setState(() {
      if (category == Category.ALL) {
        selectedCategories.clear();
      } else {
        if (selectedCategories.contains(category)) {
          selectedCategories.remove(category);
        } else {
          selectedCategories.add(category);
        }
        selectedCategories.remove(Category.ALL);
      }
    });
    fetchProducts();
  }

  void applyPriceFilter(String filter) {
    setState(() {
      selectedPriceFilter = filter;
    });
    fetchProducts();
  }

  Future<void> toggleFavorite(String userId, Clothing product) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final favoriteDoc = userDoc.collection('favorites').doc(product.id.toString());
    final favoriteSnapshot = await favoriteDoc.get();

    if (favoriteSnapshot.exists) {
      // Remove the product from favorites
      await favoriteDoc.delete();
      setState(() {
        favoriteProductIds.remove(product.id.toString());
      });
    } else {
      // Add the product to favorites
      await favoriteDoc.set({
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.image,
      });
      setState(() {
        favoriteProductIds.add(product.id.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    // Fetch user's favorite products on login or when the page loads
    if (favoriteProductIds.isEmpty) {
      fetchFavorites(userId); // Fetch favorite products on login
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: categories.map((category) {
                bool isSelected = selectedCategories.contains(category) || (selectedCategories.isEmpty && category == Category.ALL);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(categoryValues.reverse[category] ?? ''),
                    selected: isSelected,
                    onSelected: (_) => toggleCategory(category),
                    backgroundColor: Colors.grey[300],
                    selectedColor: Colors.purple,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
          // Price filter buttons (Price: Low to High / High to Low)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // Low to High Price Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text("Price: Low to High"),
                      selected: selectedPriceFilter == 'asc',
                      onSelected: (_) => applyPriceFilter('asc'),
                      backgroundColor: Colors.grey[300],
                      selectedColor: Colors.purple,
                      labelStyle: TextStyle(color: selectedPriceFilter == 'asc' ? Colors.white : Colors.black),
                    ),
                  ),
                  // High to Low Price Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text("Price: High to Low"),
                      selected: selectedPriceFilter == 'desc',
                      onSelected: (_) => applyPriceFilter('desc'),
                      backgroundColor: Colors.grey[300],
                      selectedColor: Colors.purple,
                      labelStyle: TextStyle(color: selectedPriceFilter == 'desc' ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for products...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
                fetchProducts();
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products == null || products!.isEmpty
                    ? const Center(child: Text("No products found"))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MasonryGridView.builder(
                          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: products!.length,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemBuilder: (context, index) {
                            return _buildProductCard(products![index], favoriteProvider, userId);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Clothing product, FavoriteProvider favoriteProvider, String userId) {
    bool isFavorite = favoriteProductIds.contains(product.id.toString());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              sizes: const ["S", "M", "L", "XL"],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'hero_${product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                      toggleFavorite(userId, product);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}




// Custom search delegate to handle search functionality

class CustomSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  CustomSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear search query
          onSearch(query); // Trigger search
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search bar
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);  // Apply search when user submits query
    return Container(); // No extra UI needed, as we're handling search on the same page
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Suggestions can be optional or left empty
  }
}

