import 'package:flutter/material.dart';
import 'package:wx_styleloft_project_flutter/screens/register_page.dart';
import '../screens/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (covering entire screen)
          Positioned.fill(
            child: Image.asset(
              'images/Welcome.jpg', // Replace with your image path
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Darken overlay (semi-transparent black)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity for darkness
            ),
          ),
          // Container with white background for the content, positioned at the bottom
          Positioned(
            bottom: 0, // Adjust this value to control how far from the bottom it is
            left: 10, // Optional: controls the horizontal positioning
            right: 10, // Optional: controls the horizontal positioning
            child: Container(
              height: 450,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), // Circular border for top-left
                  topRight: Radius.circular(20), // Circular border for top-right
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(5, 5),
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Centered Logo Image
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'images/Logo.png', // Replace with your logo image path
                      height: 120, // Adjust the size of the logo
                      width: 160,  // Adjust the size of the logo
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "We Don't Make StyleLoft.",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "We Make StyleLoft Better!",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "StyleLoft where fashion meets style",
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  // ElevatedButton for SignIn
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to LoginPage() with slide transition
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Slide transition
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ElevatedButton for Sign In
                  SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to RegisterPage() with slide transition
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Register Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
