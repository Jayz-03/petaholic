import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class AddPetProfileScreen extends StatefulWidget {
  const AddPetProfileScreen({super.key});

  @override
  _AddPetProfileScreenState createState() => _AddPetProfileScreenState();
}

class _AddPetProfileScreenState extends State<AddPetProfileScreen> {
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  String? _selectedSex;
  File? _selectedImage; // To hold the picked image
  bool _isSaving = false; // To track saving state
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Styled TextFormField widget
  Widget _buildStyledTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: GoogleFonts.lexend(color: Colors.white),
      controller: controller,
      cursorColor: Colors.white54,
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.white54),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.white.withOpacity(0.2),
        filled: true,
        prefixIcon: Icon(icon, color: Colors.white),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Function to save the pet profile to Firebase
  Future<void> _savePetProfile() async {
    if (_formKey.currentState!.validate() && currentUser != null) {
      setState(() {
        _isSaving = true; // Show loading indicator
      });

      String? imageUrl;

      // Upload image to Firebase Storage if an image is selected
      if (_selectedImage != null) {
        final storageRef = _storage
            .ref()
            .child('pet_profiles')
            .child(currentUser!.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final petProfileData = {
        'petName': _petNameController.text.trim(),
        'breed': _breedController.text.trim(),
        'color': _colorController.text.trim(),
        'sex': _selectedSex,
        'dateOfBirth': _dateOfBirthController.text.trim(),
        'profileImage': imageUrl, // Save image URL
      };

      // Save to Firebase Realtime Database under the current user's ID
      await _databaseRef
          .child('PetProfiles')
          .child(currentUser!.uid)
          .push()
          .set(petProfileData);

      setState(() {
        _isSaving = false; // Hide loading indicator
        _petNameController.clear();
        _breedController.clear();
        _colorController.clear();
        _dateOfBirthController.clear();
        _selectedSex = null;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Pet profile saved successfully!')),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  // Function to select Date of Birth using a date picker
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        title: Text('Add Pet Profile',
            style: GoogleFonts.lexend(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(fit: StackFit.expand, children: [
        Image.asset(
          'assets/images/bgside1.png',
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? Icon(Iconsax.add, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStyledTextFormField(
                  controller: _petNameController,
                  hintText: 'Pet Name',
                  icon: Iconsax.pet,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the pet name' : null,
                ),
                const SizedBox(height: 16),
                _buildStyledTextFormField(
                  controller: _breedController,
                  hintText: 'Breed',
                  icon: Iconsax.tag,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the breed' : null,
                ),
                const SizedBox(height: 16),
                _buildStyledTextFormField(
                  controller: _colorController,
                  hintText: 'Color',
                  icon: Iconsax.color_swatch,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the color' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    prefixIcon: Icon(Iconsax.user, color: Colors.white),
                    hintText: 'Select Sex',
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: GoogleFonts.lexend(color: Colors.black),
                  value: _selectedSex,
                  items: ['Male', 'Female'].map((String sex) {
                    return DropdownMenuItem<String>(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSex = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select sex' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDateOfBirth(context),
                  child: AbsorbPointer(
                    child: _buildStyledTextFormField(
                      controller: _dateOfBirthController,
                      hintText: 'Date of Birth',
                      icon: Iconsax.calendar,
                      validator: (value) => value!.isEmpty
                          ? 'Please select the date of birth'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isSaving)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _savePetProfile,
                    child: Text(
                      'Save Profile',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
