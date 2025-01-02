import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholic/screens/messages/messages.dart';

class TelemedicineScreen extends StatefulWidget {
  @override
  _TelemedicineScreenState createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');
  late final String userId;
  late StreamSubscription _appointmentsSubscription;
  List<Map<String, dynamic>> _approvedAppointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _fetchApprovedAppointments();
  }

  void _fetchApprovedAppointments() {
    _appointmentsSubscription =
        _appointmentsRef.child(userId).onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      List<Map<String, dynamic>> approved = [];

      for (var appointmentId in data.keys) {
        final appointmentData = Map<String, dynamic>.from(data[appointmentId]);
        if (appointmentData['status'] == 'Approved') {
          appointmentData['appointmentId'] = appointmentId;
          approved.add(appointmentData);
        }
      }

      if (mounted) {
        setState(() {
          _approvedAppointments = approved;
          _filteredAppointments = approved; // Initialize with all appointments
          _isLoading = false;
        });
      }
    });
  }

  void _filterAppointments(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredAppointments = _approvedAppointments;
      });
    } else {
      setState(() {
        _filteredAppointments = _approvedAppointments
            .where((appointment) =>
                appointment['service']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                appointment['appointmentDate']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _appointmentsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        title: Text(
          'My Appointments',
          style: GoogleFonts.lexend(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bgscreen.png',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterAppointments(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey),
                    hintText: 'Search appointments...',
                    hintStyle: GoogleFonts.lexend(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 0, 86, 99),
                        ),
                      )
                    : _filteredAppointments.isEmpty
                        ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/questionmark.png',
                                  width: 200,
                                  height: 200,
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  'There is no appointment match found!',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment =
                                  _filteredAppointments[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                elevation: 4,
                                color: Colors.white,
                                child: ListTile(
                                  leading: Image.asset(
                                      "assets/images/petaholic-logo.png",
                                      height: 30),
                                  title: Text(
                                    '${appointment['service']} - ${appointment['appointmentDate']}',
                                    style: GoogleFonts.lexend(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 0, 86, 99),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Tap to view messages',
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MessagesScreen(
                                          service: appointment['service'],
                                          appointmentId:
                                              appointment['appointmentId'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
