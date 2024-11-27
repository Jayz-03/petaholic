import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
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

  // Function to save the pet profile to Firebase
  void _savePetProfile() async {
    if (_formKey.currentState!.validate() && currentUser != null) {
      final petProfileData = {
        'petName': _petNameController.text.trim(),
        'breed': _breedController.text.trim(),
        'color': _colorController.text.trim(),
        'sex': _selectedSex,
        'dateOfBirth': _dateOfBirthController.text.trim(),
      };

      // Save to Firebase Realtime Database under the current user's ID
      await _databaseRef
          .child('PetProfiles')
          .child(currentUser!.uid)
          .push()
          .set(petProfileData);

      // Clear fields after saving
      _petNameController.clear();
      _breedController.clear();
      _colorController.clear();
      _dateOfBirthController.clear();
      setState(() => _selectedSex = null);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet profile saved successfully!')),
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
                // Sex Dropdown
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
                // Date of Birth Field
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
