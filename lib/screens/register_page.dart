import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import 'package:wx_styleloft_project_flutter/services/firebaseauth_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'images/Logo.png',
                  height: 120,
                  width: 160,
                ),
              ),
              const SizedBox(height: 40),
              const Text("Create Account", style: TextStyle(fontSize: 25)),
              const SizedBox(height: 10),
              const Text("Join us today and get started!", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 50),
              // Name field
              buildTextField('Name', nameController, true),
              // Contact field
              buildTextField('Contact', contactController, true),
              // Address field
              buildTextField('Address', addressController, true),
              // Email field
              buildTextField('Email', emailController, true),
              // Password field
              buildTextField('Password', passwordController, true),
              const SizedBox(height: 20),
              SizedBox(
                width: 380,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
               Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Slide transition
                              const begin = Offset(0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                },
                child: const Text('Already have an account? Sign In',
                 style: TextStyle(color:Colors.black,
              decoration: TextDecoration.underline),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build TextField widget
  Padding buildTextField(String label, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: label == 'Password',
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

  // Register function with contact number validation and uniqueness check
  Future<void> _register() async {
    // Check if all fields are filled
    if (nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Validate contact number (only numbers, length check)
    String contactNumber = contactController.text.trim();
    RegExp contactRegExp = RegExp(r'^[0-9]+$'); // Only numbers
    if (!contactRegExp.hasMatch(contactNumber) || contactNumber.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid contact number (8 digits)')),
      );
      return;
    }

    // Check if the contact number already exists
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('contact', isEqualTo: contactController.text.trim())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If a document exists with the same contact number
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number already in use!')),
      );
      return;
    }

    // Proceed with the registration
    var user = await FirebaseAuthService().signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    if (user != null) {
      // Store additional user info in Firestore
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text.trim(),
        'contact': contactController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
      });

      // Show success message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Account Created'),
            content: const Text('Your account has been successfully created!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }
}
