import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wx_styleloft_project_flutter/model/cartprovider.dart';
import 'landingpage.dart';
import 'package:flutter/services.dart';
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(child: Text('Please log in to view your cart')),
      );
    }

    final userCartItems = cartProvider.getCart(userId).values.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(child: Text('My Cart (${userCartItems.length})')),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => cartProvider.clearCart(userId),
          ),
        ],
      ),
      body: userCartItems.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: userCartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = userCartItems[index];

                      return Card(
                        margin: const EdgeInsets.all(5.0),
                        child: ListTile(
                          leading: Image.network(cartItem.imgPath, width: 50, height: 50, fit: BoxFit.contain),
                          title: Text(cartItem.producttitle.toString()),
                          subtitle: Text("Size: ${cartItem.size} | Qty: ${cartItem.quantity} | \$${cartItem.price}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cartProvider.removeFromCart(userId, cartItem.cartId),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Total: \$${cartProvider.getTotalPrice(userId).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: userCartItems.isEmpty
                            ? null
                            : () => showPaymentDialog(context, cartProvider, userId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text("Proceed to Payment"),
                      ),
                      if (userCartItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Add items to your cart to proceed with payment.", style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

void showPaymentDialog(BuildContext context , CartProvider cartProvider , String userId) {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Enter Payment Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Card Number"),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                LengthLimitingTextInputFormatter(19), // Max length (16 digits + 3 spaces)
                CardNumberFormatter(), // Auto-spacing after 4 digits
              ],
            ),
            TextField(
              controller: expiryDateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(labelText: "Expiry Date (MM/YY)"),
            ),
            TextField(
              controller: cvvController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: "CVV"),
              inputFormatters: [
                LengthLimitingTextInputFormatter(3), // Limit to 3 digits
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
            ElevatedButton(
              onPressed: () {
                if (_validatePaymentForm(cardNumberController.text, expiryDateController.text, cvvController.text)) {
                  _handlePayment(context, cartProvider, userId);
             
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields correctly.")),
                  );
                }
              },
            child: const Text("Pay Now"),
          ),
        ],
      );
    },
  );
}


bool _validatePaymentForm(String cardNumber, String expiryDate, String cvv) {
  String cleanedCardNumber = cardNumber.replaceAll(' ', ''); // Remove spaces before validation

  final cardNumberPattern = RegExp(r'^\d{16}$'); // Expect exactly 16 digits (without spaces)
  final expiryDatePattern = RegExp(r'^\d{2}/\d{2}$'); // MM/YY format
  final cvvPattern = RegExp(r'^\d{3}$'); // 3-digit CVV

  if (cleanedCardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty) {
    return false;
  }
  if (!cardNumberPattern.hasMatch(cleanedCardNumber) ||
      !expiryDatePattern.hasMatch(expiryDate) ||
      !cvvPattern.hasMatch(cvv)) {
    return false;
  }
  return true;
}

  Future<void> _handlePayment(BuildContext context, CartProvider cartProvider, String userId) async {
    final cartItems = cartProvider.getCart(userId);
    if (cartItems.isEmpty) return;

    String orderId = const Uuid().v4(); // Generate unique order ID
    double totalAmount = cartProvider.getTotalPrice(userId);

    List<Map<String, dynamic>> orderItems = cartItems.values.map((item) {
      return {
        'productId': item.productId,
        'productName': item.producttitle,
        'imgPath': item.imgPath,
        'price': item.price,
        'quantity': item.quantity,
        'size': item.size,
      };
    }).toList();

    try {
      // Add the order to the 'orders' collection in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('orders').doc(orderId).set({
        'orderId': orderId,
        'timestamp': Timestamp.now(),
        'totalPrice': totalAmount,
        'items': orderItems,
      });

      // Clear the cart after the payment
      cartProvider.clearCart(userId);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful! Order placed.")),
      );

      // Navigate to LandingPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingPage(), // Navigate to LandingPage
        ),
      );
    } catch (e) {
      // Handle payment failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    }
  }
}



class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), ''); // Remove non-numeric characters
    String formattedText = '';

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += ' '; // Add space after every 4 digits
      }
      formattedText += digitsOnly[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}



