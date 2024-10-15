import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

import 'package:petaholic/screens/authentication/OTPVerification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;
  String generatedOTP = '';

  Future<void> _sendOTP(String email) async {
    setState(() {
      _isLoading = true;
    });

    final random = Random();
    generatedOTP = (random.nextInt(900000) + 100000).toString();

    String username = 'petaholicveterinaryclinic@gmail.com';
    String password = 'icqc rsbd umlf ztko';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Petaholic Veterinary Clinic')
      ..recipients.add(email)
      ..subject = 'Password Reset OTP'
      ..text = 'Your OTP for password reset is: $generatedOTP';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $email'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            email: email,
            sentOTP: generatedOTP,
          ),
        ),
      );
    } on MailerException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Text(
            'Forgot Password',
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
              'Close',
              style: GoogleFonts.lexend(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/images/petaholic-logo.png',
                height: 120,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Forgot Password',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              cursorColor: Color.fromARGB(255, 0, 86, 99),
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.sms),
                hintText: 'Email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 0, 86, 99),
                    width: 2.0,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      final email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        _sendOTP(email);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid email!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      'Send OTP',
                      style:
                          GoogleFonts.lexend(fontSize: 16, color: Colors.white),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 86, 99),
                minimumSize: Size(double.infinity, 50),
                textStyle:
                    GoogleFonts.lexend(fontSize: 16, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
