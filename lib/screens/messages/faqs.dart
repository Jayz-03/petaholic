import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What are your operating hours?',
      'answer': '8am-6pm Monday to Saturday, 8am-3pm Sunday.',
    },
    {
      'question': 'Do you accept walk-ins, or is it appointment only?',
      'answer': 'We accept walk-ins.',
    },
    {
      'question': 'How far in advance should I book an appointment?',
      'answer': 'For appointments, book 3-5 days before your visit.',
    },
    {
      'question':
          'What is your policy for rescheduling or canceling appointments?',
      'answer': 'You can cancel your booking.',
    },
    {
      'question': 'Do you offer after-hours emergency services?',
      'answer': 'Yes, we offer after-hours emergency services.',
    },
    {
      'question': 'How long does a typical visit or procedure take?',
      'answer': 'The time depends on the patient’s case.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'FAQs',
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
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FAQCard(
            question: faqs[index]['question']!,
            answer: faqs[index]['answer']!,
          );
        },
      ),
    );
  }
}

class FAQCard extends StatefulWidget {
  final String question;
  final String answer;

  const FAQCard({super.key, required this.question, required this.answer});

  @override
  State<FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.question,
              style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                widget.answer,
                style: GoogleFonts.lexend(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
