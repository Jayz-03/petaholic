import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _auth = FirebaseAuth.instance;
  late final DatabaseReference _appointmentsRef;
  late StreamSubscription<DatabaseEvent> _appointmentsSubscription;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _appointmentsRef =
        FirebaseDatabase.instance.ref('Appointments/${_auth.currentUser?.uid}');
    _appointmentsSubscription = _appointmentsRef.onValue.listen((event) {
      _calculateUnreadCount();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _appointmentsSubscription.cancel();
    super.dispose();
  }

  Future<void> _calculateUnreadCount() async {
    final appointmentsSnapshot = await _appointmentsRef.get();
    final data = appointmentsSnapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final unreadCount = data.values.where((appointment) {
        final appointmentData = appointment as Map<dynamic, dynamic>;
        return appointmentData['userActive'] == 'Yes';
      }).length;

      setState(() {
        _unreadCount = unreadCount;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final appointmentsSnapshot = await _appointmentsRef.get();
    final data = appointmentsSnapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      for (var entry in data.entries) {
        final appointmentRef = _appointmentsRef.child(entry.key);
        await appointmentRef.update({'userActive': 'No'});
      }

      setState(() {
        _unreadCount = 0;
      });
    }
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
          'Notification',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'Mark All as Read',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 86, 99),
                        ),
                      ),
                    ),
                    Text(
                      'Unread: $_unreadCount',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 86, 99),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _appointmentsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 0, 86, 99),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data =
                    snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                if (data == null) {
                  return Center(
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
                          'No notification available!',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 86, 99),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final appointments = data.entries.map((entry) {
                  final appointment = entry.value as Map<dynamic, dynamic>;
                  return {
                    'key': entry.key,
                    'service': appointment['service'] as String,
                    'date': appointment['appointmentDate'] as String,
                    'time': appointment['appointmentTime'] as String,
                    'timestamp': appointment['timestamp'] as int,
                    'userActive': appointment['userActive'] as String,
                  };
                }).toList();

                appointments
                    .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final date =
                        DateFormat('yyyy-MM-dd').parse(appointment['date']);
                    final formattedDate =
                        DateFormat('EEEE, MMMM d, yyyy').format(date);
                    final time = appointment['time'];
                    final createdAt = DateTime.fromMillisecondsSinceEpoch(
                        appointment['timestamp']);
                    final timeAgo = timeago.format(createdAt);

                    return Container(
                      color: appointment['userActive'] == 'Yes'
                          ? Colors.white
                          : Colors.grey[300],
                      child: Stack(
                        children: [
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              ListTile(
                                leading: Icon(Iconsax.notification,
                                    color: Color.fromARGB(255, 0, 86, 99)),
                                title: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'You have an appointment for ',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${appointment['service']}',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' on ',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$formattedDate',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' from ',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$time',
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => _showAppointmentDetails(
                                    context, appointment),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, bottom: 4),
                                  child: Text('$timeAgo',
                                      style: GoogleFonts.lexend(
                                        color: Colors.black,
                                      )),
                                ),
                              ),
                            ],
                          ),
                          if (appointment['userActive'] == 'No')
                            Positioned.fill(
                              child: Container(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppointmentDetails(
      BuildContext context, Map<String, dynamic> appointment) async {
    final appointmentRef = _appointmentsRef.child(appointment['key']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Appointment Details',
          style: GoogleFonts.lexend(
            fontSize: 20,
            color: Color.fromARGB(255, 0, 86, 99),
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Service: ${appointment['service']}',
              style: GoogleFonts.lexend(fontSize: 16),
            ),
            Text(
              'Date: ${appointment['date']}',
              style: GoogleFonts.lexend(fontSize: 16),
            ),
            Text(
              'Time: ${appointment['time']}',
              style: GoogleFonts.lexend(fontSize: 16),
            ),
            Text(
              'Date: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(appointment['timestamp']))}',
              style: GoogleFonts.lexend(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await appointmentRef.update({'userActive': 'No'});
              setState(() {});
            },
            child: Text(
              'OK',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 86, 99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
