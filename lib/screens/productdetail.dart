import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wx_styleloft_project_flutter/model/cartprovider.dart';
import 'package:wx_styleloft_project_flutter/model/clothing.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:badges/badges.dart' as badges;
import 'cartpage.dart';  // Import your CartPage

class ProductDetailPage extends StatefulWidget {
  final Clothing product;
  final List<String> sizes;  // Accept the sizes list as a parameter

  const ProductDetailPage({super.key, required this.product, required this.sizes});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedSize = '';
  int chosenQuantity = 0;

  @override
  void initState() {
    super.initState();
    // Default to the first size if available
    if (widget.sizes.isNotEmpty) {
      selectedSize = widget.sizes[0];
    }
  }

  // Validation function
  bool validateInputs() {
    if (selectedSize.isEmpty) {
      // No size selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size')),
      );
      return false;
    } else if (chosenQuantity <= 0) {
      // No quantity selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quantity')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;  // Get the current logged-in user ID

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.product.title)),
        body: const Center(child: Text('Please log in to add to cart')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(child: Text('Product Page')),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              splashColor: Colors.redAccent,
              highlightColor: Colors.blueAccent.withOpacity(0.5),
              onTap: () {
                if (cartProvider.getCart(userId).isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                } else {
                  // Show message if no item is in the cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a size and quantity to proceed to the cart.")),
                  );
                }
              },
              child: badges.Badge(
                badgeContent: Text(
                  cartProvider.getCartCount(userId).toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red,
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Center(
                child: Hero(
                  tag: 'hero_${widget.product.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      widget.product.image,
                      height: 280,
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
             Container(
      decoration: BoxDecoration(
      border: Border.all(
      color: Colors.black, // Border color
      width: 2.0, // Border width
      ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Product title and price
                Text(
                  widget.product.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${widget.product.price}',
                  style: const TextStyle(fontSize: 18, color: Colors.purple),
                ),
                const SizedBox(height: 20),
                // Product description
                Text(
                  widget.product.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 20),
                // Size selection using ToggleButtons
                const Text(
                  'Select Size:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                  const SizedBox(height: 10),
              ToggleButtons(
                isSelected: widget.sizes.map((size) => size == selectedSize).toList(),
                onPressed: (int index) {
                  setState(() {
                    selectedSize = widget.sizes[index];  // Update selected size
                  });
                },
                children: widget.sizes.map((size) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(size),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Quantity section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Quantity:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        chosenQuantity += 1;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                  Text(
                    chosenQuantity.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      if (chosenQuantity > 0) {
                        setState(() {
                          chosenQuantity -= 1;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                ],
              ),
                            const SizedBox(height: 10),
              // Add to Cart Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Validate inputs
                    if (validateInputs()) {
                      // Add to cart functionality
                      cartProvider.addToCart(
                        cartId: DateTime.now().millisecondsSinceEpoch,  // Use productId as cartId
                        userId: userId,  // Pass the logged-in user ID
                        productId: widget.product.id,
                        producttitle: widget.product.title,
                        size: selectedSize,
                        imgPath: widget.product.image,
                        price: widget.product.price.toString(),
                        quantity: chosenQuantity,
                      );

                      // Show confirmation snack bar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    }
                  },
                  child: const Text("Add to Cart"),
                ),
              ),
          ],
          ),
        ),
        
      ),
            
            

            ],
          ),
        ),
      ),
    );
  }
}
