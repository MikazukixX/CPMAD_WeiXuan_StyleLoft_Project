//ignore_for_file:unused_import
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/startpage.dart';
import 'screens/login_page.dart';
import 'model/cartprovider.dart';
import 'model/favouriteprovider.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()), // Add CartProvider
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleLoft Project',
      theme: ThemeData(
        primarySwatch: Colors.purple, // Change primary color
        primaryColor: Colors.purple,  // This controls the color of AppBar and other elements
        scaffoldBackgroundColor: Colors.white, // Change the background color of Scaffold
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Change body text color
          bodyMedium: TextStyle(color: Colors.black), // Change body text color
        ),
        indicatorColor: Colors.purple, // Change the color of indicators like CircularProgressIndicator
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.purple, // Change button color
          textTheme: ButtonTextTheme.primary, // Set button text to primary color
        ),
      ),
      home: const HomePage(),
    );
  }
}