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
        title: Text(
          'Legal Terms',
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
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: 'Terms and Conditions\n\n',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'Effective Date: [Insert Date]\n\n',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      'By using the "Petaholic Veterinary Clinic" mobile app, you agree to these Terms and Conditions. If you disagree, do not use the App.\n\n'
                      'By using the App, you acknowledge that you have read, understood, and agree to comply with these terms.\n\n'
                      'To access certain features, you must create an account. You agree to provide accurate information and maintain the confidentiality of your account credentials.\n\n'
                      'You agree to provide truthful information about your pet, comply with laws, and not misuse the App for harmful activities. Do not disrupt or interfere with the App’s services.\n\n'
                      'We respect your privacy. Refer to our Privacy Policy for how we handle your personal data. By using the App, you consent to the collection and use of your data.\n\n'
                      'Do not harass others, infringe intellectual property rights, or upload harmful content like viruses or malware.\n\n'
                      'All content on the App is owned by Petaholic Veterinary Clinic or its licensors. You may not use it without permission.\n\n'
                      'Petaholic Veterinary Clinic is not liable for any indirect, incidental, or consequential damages related to your use of the App.\n\n'
                      'We may update these terms at any time. Changes take effect immediately upon posting. Check regularly for updates.\n\n'
                      'We may suspend or terminate your access if you violate these terms. Upon termination, your right to use the App ends immediately.\n',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
