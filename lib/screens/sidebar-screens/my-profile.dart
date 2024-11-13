import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholic/screens/authentication/login.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users');
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser != null) {
      try {
        final snapshot = await databaseRef.child(currentUser!.uid).get();
        if (snapshot.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Iconsax.lock,
            size: 100,
            color: Color.fromARGB(255, 0, 86, 99),
          ),
          content: TextField(
            controller: newPasswordController,
            style: GoogleFonts.lexend(),
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.lock, size: 24),
              hintText: 'Enter new password',
              hintStyle: GoogleFonts.lexend(),
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
            obscureText: true,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.lexend(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 86, 99),
                    textStyle: GoogleFonts.lexend(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    try {
                      await currentUser
                          ?.updatePassword(newPasswordController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Center(
                                child: Text('Password changed successfully!')),
                            backgroundColor: Color.fromARGB(255, 0, 86, 99)),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Center(
                                child: Text('Failed to change password: $e')),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text(
                    'Change',
                    style:
                        GoogleFonts.lexend(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 86, 99),
                    textStyle: GoogleFonts.lexend(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'My Profile',
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 0, 86, 99)))
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        userData?['profileImageUrl'] ??
                            "https://i.pinimg.com/originals/73/17/a5/7317a548844e0d0cccd211002e0abc45.jpg",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${userData?['firstName'] ?? 'John'} ${userData?['lastName'] ?? 'Doe'}",
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData?['email'] ?? "No email available",
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 7,
                        margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 0, 86, 99),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 35),
                ...List.generate(
                  customListTiles.length,
                  (index) {
                    final tile = customListTiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        color: Color.fromARGB(255, 0, 86, 99),
                        elevation: 4,
                        shadowColor: Colors.black12,
                        child: ListTile(
                          leading: Icon(
                            tile.icon,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          title: Text(
                            tile.title,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          trailing: Icon(
                            Iconsax.arrow_right_2,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          onTap: () {
                            if (tile.title == "Sign Out") {
                              _signOut(context);
                            } else if (tile.title == "Personal Information") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(userData: userData),
                                ),
                              );
                            } else if (tile.title == "Password & Security") {
                              _changePassword();
                            }
                          },
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  EditProfileScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final TextEditingController firstNameController =
        TextEditingController(text: userData?['firstName']);
    final TextEditingController lastNameController =
        TextEditingController(text: userData?['lastName']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_2,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Profile",
              style: GoogleFonts.lexend(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: firstNameController,
              hintText: 'First Name',
              prefixIcon:
                  Icon(Iconsax.user, color: Color.fromARGB(255, 0, 86, 99)),
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: lastNameController,
              hintText: 'Last Name',
              prefixIcon:
                  Icon(Iconsax.user, color: Color.fromARGB(255, 0, 86, 99)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateUserData(
                  userId: userId,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                ).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                        child: Text(
                          'Profile updated successfully!',
                          style: GoogleFonts.lexend(),
                        ),
                      ),
                      duration: Duration(seconds: 3),
                      backgroundColor: Color.fromARGB(255, 0, 86, 99),
                    ),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error updating profile: $error',
                        style: GoogleFonts.lexend(),
                      ),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              },
              child: Text(
                'Save Changes',
                style: GoogleFonts.lexend(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 86, 99),
                minimumSize: Size(double.infinity, 50),
                textStyle: GoogleFonts.lexend(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserData({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    final databaseReference = FirebaseDatabase.instance.ref();

    await databaseReference.child('users/$userId').update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Icon prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Color.fromARGB(255, 0, 86, 99),
      style: GoogleFonts.lexend(),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        if (hintText == 'Email' && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: Iconsax.lock,
    title: "Password & Security",
  ),
  CustomListTile(
    title: "Personal Information",
    icon: Iconsax.user,
  ),
  CustomListTile(
    title: "Sign Out",
    icon: Iconsax.logout,
  ),
];
