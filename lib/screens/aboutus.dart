import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  late GoogleMapController mapController;

  final LatLng _serangoonNex = const LatLng(1.3578, 103.8728); // Serangoon Nex
  final LatLng _angMoKioHub = const LatLng(1.3691, 103.8490); // Ang Mo Kio Hub
  final Set<Marker> _markers = {}; // Store markers

  @override
  void initState() {
    super.initState();
    _addMarkers(); // Add markers immediately
  }

  void _addMarkers() {
    setState(() {
      _markers.addAll([
        Marker(
          markerId: const MarkerId('serangoon_nex'),
          position: _serangoonNex,
          infoWindow: const InfoWindow(title: 'Serangoon Nex', snippet: 'First Store'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet), // Purple marker
        ),
        Marker(
          markerId: const MarkerId('ang_mo_kio_hub'),
          position: _angMoKioHub,
          infoWindow: const InfoWindow(title: 'Ang Mo Kio Hub', snippet: 'Second Store'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet), // Purple marker
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Hero banner image
            Container(
              height: 180,
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
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "About Us",
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
            // Text description wrapped in a container
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome to StyleLoft!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Our mission is to provide high-quality service and products. Our team is dedicated to ensuring customer satisfaction at every step.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Locate Us',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Map view inside a container with controlled width and height
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: 350, // Controlled width
                        height: 300, // Controlled height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _serangoonNex,
                              zoom: 13.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                            },
                            markers: _markers,
                            zoomControlsEnabled: true, // Enable zoom-in & zoom-out
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      'Address:\nSerangoon Nex #01-25 523120 \nAng Mo Kio Hub #03-12 545120  ',
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
