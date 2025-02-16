import 'package:wx_styleloft_project_flutter/screens/register_page.dart';
import 'package:wx_styleloft_project_flutter/services/firebaseauth_services.dart';
import 'package:flutter/material.dart';
import 'landingpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'images/Logo.png', // Replace with your logo image path
                height: 120, // Adjust the size of the logo
                width: 160,  // Adjust the size of the logo
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Hello Again!",
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome back! You've been missed",
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 50),
            Padding(
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
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Email',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
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
                    obscureText: true, // hide password
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Password',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 380,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  var user = await FirebaseAuthService().signIn(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  if (user != null) {
                 // ignore: use_build_context_synchronously
                 Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LandingPage(),
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Set button color to black
                ),
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            // Fade transition
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
              child: const Text('Don\'t have an account? Sign Up',
              style: TextStyle(color:Colors.black,
              decoration: TextDecoration.underline),),
            ),
          ],
        ),
      ),
    );
  }
}
