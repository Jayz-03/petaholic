import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:petaholic/screens/messages/faqs.dart';
import 'package:petaholic/screens/messages/videoCall.dart';

class MessagesScreen extends StatefulWidget {
  final String service;
  final String appointmentId;

  const MessagesScreen(
      {super.key, required this.service, required this.appointmentId});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref();
  late final String userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() {
      _isLoading = false;
    });
  }

  void sendMessage(String message) {
    if (message.isEmpty) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _chatRef
        .child('Chats/$userId/${widget.appointmentId}/messages')
        .push()
        .set({
      'senderId': userId,
      'message': message,
      'timestamp': timestamp,
    });

    _messageController.clear();
  }

  void requestVideoCallApproval() async {
    final appointmentSnapshot = await _chatRef
        .child('Appointments/$userId/${widget.appointmentId}')
        .get();

    if (appointmentSnapshot.exists) {
      final appointmentData =
          appointmentSnapshot.value as Map<dynamic, dynamic>;

      final callApprovalSnapshot = await _chatRef
          .child('calls/$userId/${widget.appointmentId}/videoCallApproval')
          .get();

      if (callApprovalSnapshot.exists) {
        final callApprovalData =
            callApprovalSnapshot.value as Map<dynamic, dynamic>;

        // If status is 'approved', navigate to VideoCallScreen
        if (callApprovalData['status'] == 'approved') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallScreen(),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Request Pending'),
              content: const Text(
                  'Your video call request is still pending approval. Please wait for the admin to approve.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        _chatRef
            .child('calls/$userId/${widget.appointmentId}/videoCallApproval')
            .set({
          'status': 'pending',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }).then((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Iconsax.video, color: Color.fromARGB(255, 0, 86, 99)),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Video Call Request Sent!',
                        style: GoogleFonts.lexend(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Your video call request has been sent to the admin for approval.',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: GoogleFonts.lexend(
                          fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      }
    } else {
      // Handle case where appointment is not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Appointment not found.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: Color.fromARGB(255, 0, 86, 99)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.service,
              style: GoogleFonts.lexend(
                fontSize: 18,
                color: Color.fromARGB(255, 0, 86, 99),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Petaholic Veterinary',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Color.fromARGB(255, 0, 86, 99),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.video, color: Color.fromARGB(255, 0, 86, 99)),
            onPressed: requestVideoCallApproval,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRef
                  .child('Chats/$userId/${widget.appointmentId}/messages')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 0, 86, 99),
                  ));
                }
                if (!snapshot.hasData || snapshot.data.snapshot.value == null) {
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
                          textAlign: TextAlign.center,
                          'No messages yet, but you can start \nconversation with Petaholic Veterinary \nfor your appointment ${widget.service}.',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 86, 99),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                Map messages = snapshot.data.snapshot.value as Map;
                List messageList = messages.values.toList();
                messageList
                    .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    bool isSender = messageList[index]['senderId'] == userId;
                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSender
                              ? Color.fromARGB(255, 0, 86, 99)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          messageList[index]['message'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Iconsax.message_question,
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FAQScreen()),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    cursorColor: Color.fromARGB(255, 0, 86, 99),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.lexend(
                        color: Colors.grey,
                      ),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 0, 86, 99),
                  ),
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
