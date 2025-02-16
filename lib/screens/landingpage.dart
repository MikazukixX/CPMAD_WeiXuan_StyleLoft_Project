import 'package:flutter/material.dart';
import 'package:wx_styleloft_project_flutter/screens/cartpage.dart';
import 'producthome.dart'; // Import the ProductListPage
import 'package:firebase_auth/firebase_auth.dart';
import 'profilepage.dart';
import 'startpage.dart';
import 'dart:async';
import 'favouritepage.dart';
import 'OrderHistory.dart';
import 'aboutus.dart';



class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0; // This will track the selected page

  // Define the pages for each icon
  final List<Widget> _pages = [
    const LandingHomePage(),  // Instead of adding LandingPage here, put HomePage or another page as the initial
    const ProfilePage(),
    const FavoritePage(),
    const AboutUsPage(),
    const ProductListPage(), // Product List Page
    const OrderHistoryPage(),
  ];

  // Handle navigation to other pages
  void _onPageSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'E-commerce Shop',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // Cart icon on the right side
          
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Handle cart icon press
              Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  const CartPage())
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout), // Logout icon on the left
 onPressed: () async {
            await FirebaseAuth.instance.signOut(); // Firebase logout
            // Handle logout and navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Top-left corner rounded
            topRight: Radius.circular(30), // Top-right corner rounded
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Icon with text, navigate to HomePage
            _buildNavItem(Icons.home, 'Home', 0),
            // Profile Icon with text
            _buildNavItem(Icons.person, 'Profile', 1),
            // Product Icon with text
            _buildNavItem(Icons.view_list, 'Products', 4),
            // Favorites Icon with text
            _buildNavItem(Icons.favorite, 'Favorites', 2),
            // About Us Icon with text
            _buildNavItem(Icons.info, 'About Us', 3),
            
              _buildNavItem(Icons.history, 'History', 5),
            
          ],
        ),
      ),
    );
  }

  // Build each navigation icon with text
  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        _onPageSelected(index); // Select page based on index
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(
              icon,
              size: 26,
              color: _selectedIndex == index ? Colors.purple : Colors.grey,
            ),
        
          const SizedBox(height: 4), // Space between icon and text
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _selectedIndex == index ? Colors.purple : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}



class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Favorites Page'));
  }
}


class LandingHomePage extends StatelessWidget {
  const LandingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
 return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageGalleryScreen(),
    );
  }
}


class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final List<String> imagePaths = [
    'images/Imggallery1.jpg',
    'images/Imggallery2.jpg',
    'images/Imggallery3.jpg',
    'images/Imggallery4.jpg',
    'images/Imggallery5.jpg',
  ];

  String? selectedImage;
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the PageController here
    _pageController = PageController();

    // Auto-scroll the page every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first image
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
          
                  // Hero Image with opacity and text overlay
                  Container(
                    height: 150,
                    width: 400,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('images/heroimage.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4), // Add opacity to the image
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Welcome to StyleLoft!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  const SizedBox(height: 15),
          
                  const Text("Gallery",
                  style: TextStyle(color: Colors.black,
                  fontSize:24,
                  fontWeight: FontWeight.bold)
                  ),
          
                  // Auto-scrolling gallery (horizontal scroll)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 460,
                      width: 600,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImage = imagePaths[index];
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Image.asset(imagePaths[index], fit: BoxFit.cover, width: 150),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enlarged image view when clicked
          if (selectedImage != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedImage = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 1,
                      spreadRadius: 0.1,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(selectedImage!, fit: BoxFit.contain, width: 300),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
