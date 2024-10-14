import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholic/user/screens/authentication/login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        resizeToAvoidBottomInset: true,
        body: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/images/bgside1.png',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 20),
                _header(context, width),
                _inputField(context, width),
                _signup(context, width),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context, double width) {
    return Column(
      children: [
        Image.asset(
          "assets/images/petaholic-logo.png",
          height: 150,
          width: 150,
        ),
        SizedBox(height: 20),
        Text(
          "Sign Up to BK Petaholic",
          style: GoogleFonts.lexend(
            fontSize: width * 0.068,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Please fill up the necessary credentials.",
          style: GoogleFonts.lexend(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context, double width) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          TextFormField(
            style: GoogleFonts.lexend(
              color: Colors.white,
            ),
            controller: _firstNameController,
            cursorColor: Colors.white54,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.lexend(color: Colors.white54),
              hintText: "First Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              prefixIcon: Icon(
                Iconsax.user,
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: GoogleFonts.lexend(
              color: Colors.white,
            ),
            controller: _lastNameController,
            cursorColor: Colors.white54,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.lexend(color: Colors.white54),
              hintText: "Last Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              prefixIcon: Icon(
                Iconsax.user,
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: GoogleFonts.lexend(
              color: Colors.white,
            ),
            controller: _emailController,
            cursorColor: Colors.white54,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.lexend(color: Colors.white54),
              hintText: "Email Address",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              prefixIcon: Icon(
                Iconsax.sms,
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: GoogleFonts.lexend(
              color: Colors.white,
            ),
            controller: _passwordController,
            cursorColor: Colors.white54,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.lexend(color: Colors.white54),
              hintText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              prefixIcon: Icon(
                Iconsax.lock,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: GoogleFonts.lexend(
              color: Colors.white,
            ),
            controller: _confirmPasswordController,
            cursorColor: Colors.white54,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.lexend(color: Colors.white54),
              hintText: "Confirm Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              prefixIcon: Icon(
                Iconsax.lock,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isLoading ? null : _registerUser,
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Signup",
                    style: GoogleFonts.lexend(
                      color: Color.fromARGB(255, 0, 86, 99),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _signup(BuildContext context, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: GoogleFonts.lexend(
            fontSize: width * 0.032,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: Text(
            "Log in here!",
            style: GoogleFonts.lexend(
              fontSize: width * 0.032,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        _database.child("users/${userCredential.user!.uid}").set({
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "email": _emailController.text.trim(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
