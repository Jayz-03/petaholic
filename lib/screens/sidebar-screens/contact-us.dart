import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Contact Us',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 223, 223, 223),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Logo Section
          SizedBox(
            width: mediaSize.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/petaholic-logo.png",
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Contact Information Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: const Icon(Icons.email,
                  color: Color.fromARGB(255, 0, 86, 99)),
              title: Text(
                "Email Us",
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                "bkpetaholic@gmail.com",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              onTap: () {
                // Handle email tap (e.g., open email app)
              },
            ),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: const Icon(Icons.phone,
                  color: Color.fromARGB(255, 0, 86, 99)),
              title: Text(
                "Call Us",
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                "+63 909 320 3871",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              onTap: () {
                // Handle phone tap (e.g., open dialer)
              },
            ),
          ),
          const SizedBox(height: 10),

          // Social Media Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: const Icon(Iconsax.instagram,
                  color: Color.fromARGB(255, 0, 86, 99)),
              title: Text(
                "Follow us on Instagram",
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                "@petaholicclinic",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              onTap: () {
                // Handle Instagram tap
              },
            ),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: const Icon(Icons.facebook,
                  color: Color.fromARGB(255, 0, 86, 99)),
              title: Text(
                "Like us on Facebook",
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                "Petaholic Veterinary Clinic",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              onTap: () {
                // Handle Facebook tap
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 0, 86, 99),
    );
  }
}
