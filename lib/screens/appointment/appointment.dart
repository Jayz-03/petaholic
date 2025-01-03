import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

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
  final _instructionNoteController = TextEditingController();

  String? _selectedService;
  DateTime? _selectedAppointmentDate;
  String? _selectedAppointmentTime;
  String? _selectedPetId;

  bool _isLoading = false;

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
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
  ];

  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');

  Map<String, int> _availableSlots = {};

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid);

      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _fullNameController.text =
              '${userData['firstName']} ${userData['lastName']}';
        });
      }
    }
  }

  void _fetchAvailableSlots() async {
    if (_selectedAppointmentDate == null) {
      setState(() {
        _availableSlots = {}; // Clear slots if no date is selected
      });
      return;
    }

    final selectedDate =
        DateFormat('yyyy-MM-dd').format(_selectedAppointmentDate!);

    final snapshot = await _appointmentsRef.get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic>? appointments =
          snapshot.value as Map<dynamic, dynamic>?;

      if (appointments != null) {
        final Map<String, int> slotCounts = {};

        for (String timeSlot in _timeSlots) {
          slotCounts[timeSlot] = 0; // Initialize counts for each timeslot
        }

        // Loop through all appointments and count slots for the selected date
        appointments.forEach((userId, userAppointments) {
          (userAppointments as Map<dynamic, dynamic>)
              .forEach((appointmentId, details) {
            if (details['appointmentDate'] == selectedDate &&
                slotCounts.containsKey(details['appointmentTime'])) {
              slotCounts[details['appointmentTime']] =
                  (slotCounts[details['appointmentTime']] ?? 0) + 1;
            }
          });
        });

        setState(() {
          _availableSlots = slotCounts.map((timeSlot, count) =>
              MapEntry(timeSlot, 10 - count)); // Calculate available slots
        });
      }
    }
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
      setState(() {
        _isLoading = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String userId = user.uid;
      String appointmentId = _appointmentsRef.child(userId).push().key!;

      // Find the selected pet's details
      final selectedPet = _petsList.firstWhere(
        (pet) => pet['petName'] == _selectedPetId,
        orElse: () => {'petId': '', 'petName': ''},
      );
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Check if appointmentTime is null before proceeding
      if (_selectedAppointmentTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a valid appointment time')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final appointmentDate =
          DateFormat('yyyy-MM-dd').format(_selectedAppointmentDate!);
      final appointmentTime = _selectedAppointmentTime!; // Ensure it's not null

      // Retrieve FCM token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint("Failed to retrieve FCM token: $e");
        fcmToken = null;
      }

      Map<String, dynamic> appointmentDetails = {
        'fullName': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'instructionNote': _instructionNoteController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'service': _selectedService,
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
        'status': 'Pending',
        'petProfile': selectedPet,
        'userActive': "Yes",
        'timestamp': currentTimestamp,
        'fcmToken': fcmToken ?? '',
      };

      // Save appointment
      await _appointmentsRef
          .child(userId)
          .child(appointmentId)
          .set(appointmentDetails);

      String readableDate =
          DateFormat('MMMM d, yyyy').format(DateTime.parse(appointmentDate));

      String title = 'Appointment Booking Alert';
      String message =
          '$_fullNameController has booked an appointment on $readableDate from $appointmentTime. Services Requested: $_selectedService. Please review and confirm the booking in the system.';

      // Send push notification
      _sendPushNotification(
        fcmToken:
            "cuBTdfvDRG-nQv7i4Qyfyj:APA91bGqTrSOPQJElC3Y522jXyNHARrX9py0pB3rdqRQdpKAN6fRDQ_O1pt44GHO633imd5P0c6TV1hYE4m3svYlmB3P-4UlTzgDE-v-PCvLDH6s9Kp3NnA",
        title: title,
        body: message,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form and reset loading state
      _formKey.currentState!.reset();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    const String projectId = 'petaholic-4b075';
    final String url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    try {
      String accessToken = await _getAccessToken();

      final Map<String, dynamic> message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'new',
          },
        },
      };

      print("Sending message: ${jsonEncode(message)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully.');
      } else {
        print('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<String> _getAccessToken() async {
    try {
      final serviceAccountKey = await rootBundle
          .loadString('assets/petaholic-4b075-ab9d200ab6d8.json');

      final Map<String, dynamic> keyData = jsonDecode(serviceAccountKey);

      final accountCredentials = ServiceAccountCredentials.fromJson(keyData);

      const List<String> scopes = [
        'https://www.googleapis.com/auth/cloud-platform',
      ];

      final client = await clientViaServiceAccount(accountCredentials, scopes);

      final accessToken = client.credentials.accessToken;

      return accessToken.data;
    } catch (e) {
      throw Exception('Error getting access token: $e');
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
        children: [
          // Main UI content
          _buildMainContent(),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
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
                    controller: _instructionNoteController,
                    hintText: 'Instruction Note',
                    icon: Iconsax.document_text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide instructions or notes for the appointment';
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
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    items: _services.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(
                          service,
                          style: GoogleFonts.lexend(
                              color: Colors.white), // Set font color to white
                        ),
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
                    dropdownColor: const Color.fromARGB(
                        255, 0, 86, 99), // Set background color of dropdown
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
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedPetId,
                    items: _petsList.map<DropdownMenuItem<String>>((pet) {
                      return DropdownMenuItem<String>(
                        value: pet['petName'], // Use petName as the value
                        child: Text(
                          pet['petName'],
                          style: GoogleFonts.lexend(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.pet, color: Colors.white),
                      filled: true,
                      hintText: 'Select Pet',
                      hintStyle: const TextStyle(color: Colors.white54),
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color.fromARGB(255, 0, 86, 99),
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
                  const SizedBox(height: 10),
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
                            color: const Color.fromARGB(255, 0, 86, 99),
                          ),
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
                        // Fetch available slots when the date is selected
                        _fetchAvailableSlots();
                      }
                    },
                    child: AbsorbPointer(
                      child: _buildStyledTextFormField(
                        controller: TextEditingController(
                          text: _selectedAppointmentDate == null
                              ? 'Select Date'
                              : DateFormat('yyyy-MM-dd')
                                  .format(_selectedAppointmentDate!),
                        ),
                        hintText: 'Select Appointment Date',
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedAppointmentTime,
                    items: _timeSlots.map((timeSlot) {
                      // Get the number of available slots for the current timeSlot
                      int available = _availableSlots[timeSlot] ??
                          10; // Default to 10 available
                      bool isFullyBooked =
                          available == 0; // Check if the slot is fully booked

                      String displayText =
                          '$timeSlot [$available slots]'; // Display text with availability

                      return DropdownMenuItem(
                        value: timeSlot,
                        enabled: !isFullyBooked, // Disable if fully booked
                        child: Text(
                          displayText,
                          style: GoogleFonts.lexend(
                            color: isFullyBooked
                                ? Colors.red
                                : Colors.white, // Red for fully booked
                          ),
                        ),
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
                    dropdownColor: const Color.fromARGB(255, 0, 86, 99),
                    onChanged: (value) {
                      setState(() {
                        _selectedAppointmentTime = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a valid time slot';
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
    );
  }
}
