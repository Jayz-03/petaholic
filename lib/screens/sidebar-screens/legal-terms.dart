import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class LegalTermsScreen extends StatefulWidget {
  const LegalTermsScreen({super.key});

  @override
  State<LegalTermsScreen> createState() => _LegalTermsScreenState();
}

class _LegalTermsScreenState extends State<LegalTermsScreen> {
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Text(
            'Legal Terms',
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 223, 223, 223),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: GoogleFonts.lexend(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14.0),
        children: [
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
          ListTile(
            title: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Petaholic Veterinary Clinic\n',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: Divider(
              thickness: 1,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
    );
  }
}