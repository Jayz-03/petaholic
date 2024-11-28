import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petaholic/screens/products/productDetail.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Treats';
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('Products');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bgscreen.png',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "BK Petaholic Promos",
                        style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      PromoBanner(imageUrl: 'assets/images/banner1.png'),
                      PromoBanner(imageUrl: 'assets/images/banner1.png'),
                      PromoBanner(imageUrl: 'assets/images/banner1.png'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Services Offered",
                        style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ServicesSection(),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Featured Products",
                        style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // StreamBuilder for Featured Products
                StreamBuilder<DatabaseEvent>(
                  stream: _productsRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return Center(
                          child: Text(
                        'No products available!',
                        style: GoogleFonts.lexend(color: Colors.white),
                      ));
                    } else {
                      Map<dynamic, dynamic> products = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;
                      List<MapEntry<dynamic, dynamic>> productEntries =
                          products.entries.toList();

                      if (productEntries.isEmpty) {
                        return Center(
                          child: Text(
                            'No featured products available!',
                            style: GoogleFonts.lexend(color: Colors.white),
                          ),
                        );
                      }

                      return SizedBox(
                        height:
                            240, // Set a fixed height for horizontal ListView
                        child: ListView.builder(
                          scrollDirection:
                              Axis.horizontal, // Set to horizontal scrolling
                          itemCount: productEntries.length,
                          itemBuilder: (context, index) {
                            var product = productEntries[index].value;
                            var status = product['status'] ?? 'In stock';
                            String stockStatus;
                            Color statusColor;

                            if (status == 'Out of stock') {
                              stockStatus = 'Out of Stock';
                              statusColor = Colors.red;
                            } else if (status == 'Low stock') {
                              stockStatus = 'Low Stock';
                              statusColor = Colors.orange;
                            } else {
                              stockStatus = 'In stock';
                              statusColor = Colors.green;
                            }

                            return SizedBox(
                              width: 150,
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Add rounded corners
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Match Card radius
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                          productKey: productEntries[index].key,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(
                                              12.0), // Match top corners
                                          topRight: Radius.circular(12.0),
                                        ),
                                        child: product['photoUrl'] != null
                                            ? Image.network(
                                                product['photoUrl'],
                                                width: double.infinity,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey.shade200,
                                                height: 100,
                                                child: const Icon(Icons.image,
                                                    size: 50,
                                                    color: Colors.grey),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product['name'] ?? 'No Name',
                                          style: GoogleFonts.lexend(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          product['category'] ?? 'N/A',
                                          style: GoogleFonts.lexend(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          stockStatus,
                                          style: GoogleFonts.lexend(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "₱${product['price'].toString()}",
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromoBanner extends StatelessWidget {
  final String imageUrl;

  PromoBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10, left: 10),
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imageUrl,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class ServicesSection extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Consultation',
      'image': 'assets/images/Consultation.png',
    },
    {
      'title': 'Vaccination',
      'image': 'assets/images/Vaccination.png',
    },
    {
      'title': 'Deworming',
      'image': 'assets/images/Deworming.png',
    },
    {
      'title': 'Surgery',
      'image': 'assets/images/Surgery.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
            onTap: () {},
            child: Card(
              color: Color.fromARGB(255, 65, 128, 140),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title'],
                      style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
