import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholic/screens/products/productDetail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('Products');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 86, 99),
        title: Text(
          'Available Product List',
          style: GoogleFonts.lexend(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bgscreen.png',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by product name...',
                    hintStyle: GoogleFonts.lexend(),
                    prefixIcon:
                        const Icon(Iconsax.search_normal, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: _productsRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return Center(
                          child: Text('No products available!',
                              style: GoogleFonts.lexend(color: Colors.white)));
                    } else {
                      Map<dynamic, dynamic> products = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;
                      List<MapEntry<dynamic, dynamic>> productEntries =
                          products.entries.toList();

                      if (_searchQuery.isNotEmpty) {
                        productEntries = productEntries
                            .where((entry) => entry.value['name']
                                .toString()
                                .toLowerCase()
                                .contains(_searchQuery))
                            .toList();
                      }

                      if (productEntries.isEmpty) {
                        return Center(
                          child: Text(
                            'No search found!',
                            style: GoogleFonts.lexend(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: productEntries.length,
                        itemBuilder: (context, index) {
                          var productKey = productEntries[index].key;
                          var product = productEntries[index].value;

                          // Determine quantity and status
                          int quantity =
                              product['quantity'] ?? 0; // Default to 0 if null
                          String stockStatus;
                          Color statusColor;

                          if (quantity < 20) {
                            stockStatus = 'Low Stock';
                            statusColor = Colors.orange;
                          } else {
                            stockStatus = 'In Stock';
                            statusColor = Colors.green;
                          }

                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                        productKey: productKey),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: product['photoUrl'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product['photoUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.image),
                                title: Text(
                                  product['name'] ?? 'No Name',
                                  style: GoogleFonts.lexend(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['category'] ?? 'N/A',
                                      style: GoogleFonts.lexend(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      stockStatus,
                                      style: GoogleFonts.lexend(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Stocks: $quantity', // Display product quantity
                                      style: GoogleFonts.lexend(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  "₱${product['price'].toString()}",
                                  style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
