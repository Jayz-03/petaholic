import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholic/common/navigation-appbar.dart';
import 'package:petaholic/screens/authentication/forgotPassword.dart';
import 'package:petaholic/screens/authentication/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        resizeToAvoidBottomInset: true,
        body: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/images/bgscreen1.png',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 20),
                _header(context),
                Form(
                  key: _formKey, // Attach the form key here
                  child: _inputField(context),
                ),
                _forgotPassword(context),
                _signup(context),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        Image.asset(
          "assets/images/petaholic-logo.png",
          height: 150,
          width: 150,
        ),
        SizedBox(height: 20),
        Text(
          "Welcome to BK Petaholic",
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

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TextFormField(
          style: GoogleFonts.lexend(
            color: Colors.white,
          ),
          controller: _emailController,
          cursorColor: Colors.white54,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white54),
            hintText: "Email Address",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.2),
            filled: true,
            prefixIcon: const Icon(
              Iconsax.sms,
              color: Colors.white,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
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
            hintStyle: const TextStyle(color: Colors.white54),
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.2),
            filled: true,
            prefixIcon: const Icon(
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
              return 'Please enter your password';
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _loginUser,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  "Login",
                  style: GoogleFonts.lexend(
                    color: Color.fromARGB(255, 0, 86, 99),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
        );
      },
      child: Text(
        "Forgot Password?",
        style: GoogleFonts.lexend(
          fontSize: width * 0.032,
          color: Colors.white54,
        ),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.lexend(
            fontSize: width * 0.032,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: Text(
            "Sign up here!",
            style: GoogleFonts.lexend(
              fontSize: width * 0.032,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();

      if (email == 'petaholicveterinaryclinic@gmail.com') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Invalid email or password!')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Attempt to sign in with email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        // Check if the email is verified
        if (userCredential.user != null &&
            !userCredential.user!.emailVerified) {
          await _auth.signOut(); // Sign the user out if not verified

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email not verified! Please check your email for the verification link.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Redirect to the main app if email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SideAndTabsNavs()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Invalid email or password!')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
