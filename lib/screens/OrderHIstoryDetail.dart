import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wx_styleloft_project_flutter/model/cartprovider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'cartpage.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderData});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late List<dynamic> items;

  @override
  void initState() {
    super.initState();
    items = widget.orderData['items'] ?? [];
  }

  // Function to add a single item to the cart
  void repurchaseSingleItem(Map<String, dynamic> item) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid;  // Get current userId

    if (userId == null) {
      // If user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to repurchase items')),
      );
      return;
    }

    // Check if the id is null and provide a fallback
    final cartId = item['id'] ?? DateTime.now().millisecondsSinceEpoch;  // Fallback to unique ID

    cartProvider.addToCart(
      cartId: cartId,  // Use fallback ID if null
      userId: userId,  // Pass the logged-in user ID
      productId: item['productId'],
      producttitle: item['productName'],
      size: item['size'],
      imgPath: item['imgPath'],
      price: item['price'].toString(),
      quantity: item['quantity'],
    );

    // Show confirmation snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item has been readded to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
  final cartProvider = Provider.of<CartProvider>(context);
  final userId = FirebaseAuth.instance.currentUser?.uid;  // Get the current logged-in user ID

  Timestamp timestamp = widget.orderData['timestamp']; // Get timestamp from Firestore
  DateTime date = timestamp.toDate(); // Convert to DateTime object
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date); // Format the date

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error handling")),
        body: const Center(child: Text('Please log in to add to cart')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Order Details'),
     actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              splashColor: Colors.redAccent,
              highlightColor: Colors.blueAccent.withOpacity(0.5),
              onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${widget.orderData['id']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
            Text("Total Price: \$${widget.orderData['totalPrice'].toStringAsFixed(2)}"),
            const SizedBox(height: 10,),
            Text("Date: $formattedDate"),
            const SizedBox(height: 10),
            const Text("Items Purchased:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final imgPath = item['imgPath'];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: imgPath.isNotEmpty
                          ? Image.network(imgPath, width: 50, height: 50)
                          : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(item['productName']),
                      subtitle: Text("Size: ${item['size']} | Qty: ${item['quantity']} | \$${item['price']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => repurchaseSingleItem(item),  // Repurchase single item
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
