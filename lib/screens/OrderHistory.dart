import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrderHIstoryDetail.dart';
// Import your HttpService

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  void fetchOrderHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("ERROR: User ID is null!");
      return;
    }

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch the orders sub-collection for the specific user
      final orderDocs = await userDoc.collection('orders') // Query the orders sub-collection
          .orderBy('timestamp', descending: true) // Optional: order by timestamp
          .get();

      if (orderDocs.docs.isEmpty) {
        print("DEBUG: No orders found for user: $userId");
      } else {
        print("DEBUG: Found ${orderDocs.docs.length} orders.");
      }

      setState(() {
        orders = orderDocs.docs.map((doc) {
          return {
            "id": doc.id,
            ...doc.data()
          };
        }).toList();
      });
    } catch (e) {
      print("ERROR fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orders.isEmpty
          ? const Center(child: Text('No previous orders found!'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Order ID: ${order['id']}"),
                    subtitle: Text("Total: \$${order['totalPrice'].toStringAsFixed(2)}"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(orderData: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
