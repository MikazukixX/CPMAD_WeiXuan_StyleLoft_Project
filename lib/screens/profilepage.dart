import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // This will store the user document from Firestore
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fetch the user data from Firestore
  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      print("Fetched user data: ${userDoc.data()}");  // Print user data to debug
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        nameController.text = userData?['name'] ?? '';
        emailController.text = userData?['email'] ?? '';
        contactController.text = userData?['contact'] ?? '';
        addressController.text = userData?['address'] ?? '';
      });
    }
  }

  // Update the user data in Firestore with contact uniqueness check and validation
  Future<void> _updateUserData() async {
    // Check if the fields are not empty
    if (contactController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Validate contact number (only 8 digits)
    String contactNumber = contactController.text.trim();
    RegExp contactRegExp = RegExp(r'^[0-9]{8}$'); // Only 8 digits
    if (!contactRegExp.hasMatch(contactNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid contact number (8 digits)')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Check if the contact number already exists
        var querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('contact', isEqualTo: contactController.text.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If a document exists with the same contact number
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact number already in use!')),
          );
          return;
        }

        // If no duplicate contact number is found, update the user's data
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'contact': contactController.text.trim(),
          'address': addressController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  // Reset the fields to their default values from Firestore
  void _resetToDefault() {
    contactController.text = userData?['contact'] ?? '';
    addressController.text = userData?['address'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'images/Logo.png',
                        height: 120,
                        width: 160,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Display Name (non-editable)
                    buildTextField('Name', nameController.text, false),
                    const SizedBox(height: 20),
                    // Display Email (non-editable)
                    buildTextField('Email', emailController.text, false),
                    const SizedBox(height: 20),
                    // Display Contact (editable)
                    buildTextField('Contact', contactController.text, true),
                    const SizedBox(height: 20),
                    // Display Address (editable)
                    buildTextField('Address', addressController.text, true),
                    const SizedBox(height: 40),
                    // Update button to save changes
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        child: const Text('Update Profile'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Reset button to reset fields to default
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _resetToDefault,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: const Text('Reset to Default'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  // Helper method to build TextField widget
  Padding buildTextField(String label, String initialValue, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: label == 'Name' ? nameController :
                        label == 'Email' ? emailController :
                        label == 'Contact' ? contactController : addressController,
            enabled: isEditable,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: label,
            ),
          ),
        ),
      ),
    );
  }
}
