import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactNumberController = TextEditingController();

  String? _selectedService;
  DateTime? _selectedAppointmentDate;
  String? _selectedAppointmentTime;
  String? _selectedPetId;

  final List<String> _services = [
    'Consultation',
    'Vaccination',
    'Deworming',
    'Surgery',
    'Laboratories',
    'Grooming',
  ];

  final List<String> _timeSlots = [
    '8:00 AM - 9:00 AM',
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
  ];

  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');
  DatabaseReference? _petsRef;
  List<Map<String, dynamic>> _pets = [];

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  List<Map<String, dynamic>> _petsList = [];

  Future<void> _fetchPets() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Access the correct PetProfiles node
      DatabaseReference petsRef =
          FirebaseDatabase.instance.ref().child('PetProfiles').child(user.uid);

      // Fetch pet data from Firebase
      final snapshot = await petsRef.get();

      if (snapshot.exists) {
        setState(() {
          // Map the data to populate the _petsList with pet names and IDs
          _petsList = (snapshot.value as Map).entries.map((entry) {
            final petData = entry.value as Map;
            return {
              'petId': entry.key, // Store pet ID
              'petName': petData['petName'] as String, // Extract pet name
            };
          }).toList();
        });
      }
    }
  }

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

  Future<void> _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      String userId = user.uid;
      String appointmentId = _appointmentsRef.child(userId).push().key!;

      // Find the selected pet's details
      final selectedPet = _petsList.firstWhere(
        (pet) => pet['petName'] == _selectedPetId,
        orElse: () => {'petId': '', 'petName': ''},
      );

      Map<String, dynamic> appointmentDetails = {
        'fullName': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'service': _selectedService,
        'appointmentDate':
            DateFormat('yyyy-MM-dd').format(_selectedAppointmentDate!),
        'appointmentTime': _selectedAppointmentTime,
        'status': 'Pending',
        'petProfile': selectedPet,
      };

      await _appointmentsRef
          .child(userId)
          .child(appointmentId)
          .set(appointmentDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Appointment saved successfully!')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: GoogleFonts.lexend(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 86, 99),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bgscreen.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStyledTextFormField(
                      controller: _fullNameController,
                      hintText: 'Full Name',
                      icon: Iconsax.user,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _addressController,
                      hintText: 'Address',
                      icon: Iconsax.location,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildStyledTextFormField(
                      controller: _contactNumberController,
                      hintText: 'Contact Number',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedService,
                      items: _services.map((service) {
                        return DropdownMenuItem(
                          value: service,
                          child: Text(service, style: GoogleFonts.lexend()),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Iconsax.activity, color: Colors.white),
                        filled: true,
                        hintText: 'Select Service',
                        hintStyle: const TextStyle(color: Colors.white54),
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a service';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedPetId,
                      items: _petsList.map<DropdownMenuItem<String>>((pet) {
                        return DropdownMenuItem<String>(
                          value: pet['petName'], // Use petName as the value
                          child:
                              Text(pet['petName'], style: GoogleFonts.lexend()),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Iconsax.pet, color: Colors.white),
                        filled: true,
                        hintText: 'Select Pet',
                        hintStyle: const TextStyle(color: Colors.white54),
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedPetId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your pet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Choose Appointment Date and Time',
                            style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null &&
                            pickedDate != _selectedAppointmentDate) {
                          setState(() {
                            _selectedAppointmentDate = pickedDate;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildStyledTextFormField(
                          controller: TextEditingController(
                              text: _selectedAppointmentDate == null
                                  ? 'Select Date'
                                  : DateFormat('yyyy-MM-dd')
                                      .format(_selectedAppointmentDate!)),
                          hintText: 'Select Appointment Date',
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedAppointmentTime,
                      items: _timeSlots.map((timeSlot) {
                        return DropdownMenuItem(
                          value: timeSlot,
                          child: Text(timeSlot, style: GoogleFonts.lexend()),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.watch_later_outlined,
                            color: Colors.white),
                        filled: true,
                        hintText: 'Select Time',
                        hintStyle: const TextStyle(color: Colors.white54),
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedAppointmentTime = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a time slot';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Submit Appointment',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
