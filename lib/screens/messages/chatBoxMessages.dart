import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petaholic/screens/messages/messages.dart';

class ChatBoxScreen extends StatefulWidget {
  @override
  _ChatBoxScreenState createState() => _ChatBoxScreenState();
}

class _ChatBoxScreenState extends State<ChatBoxScreen> {
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointments');
  late final String userId;
  late StreamSubscription _appointmentsSubscription;
  List<Map<String, dynamic>> _approvedAppointments = [];
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
    });
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 0, 86, 99),
              ),
            )
          : _approvedAppointments.isEmpty
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/doglayered.png',
                        width: 200,
                        height: 200,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Currently, you don\'nt have any \napproved appointments yet.',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 86, 99),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _approvedAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _approvedAppointments[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      elevation: 4,
                      color: Colors.white,
                      child: ListTile(
                        leading: Image.asset("assets/images/petaholic-logo.png",
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
                                appointmentId: appointment['appointmentId'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
