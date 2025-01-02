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
                      PromoBanner(imageUrl: 'assets/images/banner1.jpg'),
                      PromoBanner(imageUrl: 'assets/images/banner2.jpg'),
                      PromoBanner(imageUrl: 'assets/images/banner3.jpg'),
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
                            int quantity =
                                product['quantity'] ?? 0; // Get quantity
                            String stockStatus;
                            Color statusColor;

                            if (quantity < 20) {
                              stockStatus =
                                  'Low Stock'; // Low stock when quantity is less than 20
                              statusColor = Colors.orange;
                            } else {
                              stockStatus = 'In Stock'; // In stock otherwise
                              statusColor = Colors.green;
                            }

                            return SizedBox(
                              width: 160, // Adjusted width
                              child: Card(
                                color: const Color.fromARGB(255, 65, 128,
                                    140), // Updated background color
                                elevation:
                                    6, // Increased elevation for better card visibility
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      16.0), // Larger radius for rounded corners
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      16.0), // Match Card radius
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
                                              16.0), // Match top corners
                                          topRight: Radius.circular(16.0),
                                        ),
                                        child: product['photoUrl'] != null
                                            ? Image.network(
                                                product['photoUrl'],
                                                width: double.infinity,
                                                height:
                                                    120, // Adjusted image height
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey.shade200,
                                                height: 120,
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          product['name'] ?? 'No Name',
                                          style: GoogleFonts.lexend(
                                            color: Colors
                                                .white, // Updated to white for contrast
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
                                            color: Colors
                                                .white70, // Updated to white with opacity
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          "Stock: $quantity", // Display the quantity
                                          style: GoogleFonts.lexend(
                                            color: Colors
                                                .white, // Updated to white for better readability
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        // Wrap price and stock status with Expanded to avoid overflow
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "₱${product['price'].toString()}",
                                            style: GoogleFonts.lexend(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors
                                                  .white, // Updated to white for better contrast
                                            ),
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
      'details': 'Veterinary consultations address your pet’s health concerns, offering expert advice and tailored treatment plans. Whether it’s a routine wellness check or a specific health issue, your pet’s needs are prioritized.'
    },
    {
      'title': 'Vaccination',
      'image': 'assets/images/Vaccination.png',
      'details': 'Vaccination services protect pets against common and potentially life-threatening diseases such as rabies, distemper, and parvovirus. Tailored vaccination schedules are designed to suit your pet’s age, breed, and lifestyle, ensuring long-term health and immunity.'
    },
    {
      'title': 'Deworming',
      'image': 'assets/images/deworming.png',
      'details':
          'Regular deworming services help protect pets from internal parasites like roundworms, hookworms, and tapeworms. These treatments prevent infections, improve your pet’s overall health, and reduce the risk of zoonotic transmission to humans.'
    },
    {
      'title': 'Surgery',
      'image': 'assets/images/Surgery.png',
      'details': 'Comprehensive surgical care is available for pets, ranging from routine procedures (like spaying and neutering) to more advanced operations. The clinic ensures a safe and sterile environment, utilizing modern techniques and anesthesia to ensure your pet’s comfort and recovery.'
    },
    {
      'title': 'Laboratory',
      'image': 'assets/images/Laboratory.png',
      'details': 'On-site laboratory testing provides quick and accurate results for diagnosing various health issues. Services include bloodwork, urinalysis, fecal exams, and other diagnostic tests to ensure prompt and effective treatment for your pet.'
    },
    {
      'title': 'Grooming',
      'image': 'assets/images/grooming.png',
      'details':
          'Professional grooming services keep your pets looking and feeling their best. This includes bathing, nail trimming, ear cleaning, haircuts, and coat maintenance to promote good hygiene and prevent skin issues.'
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
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.all(16.0),
                    backgroundColor: Color.fromARGB(255, 65, 128, 140),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['image'],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['title'],
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['details'],
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
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
