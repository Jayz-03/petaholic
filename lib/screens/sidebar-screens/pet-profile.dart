import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:petaholic/screens/sidebar-screens/add-pet-profile.dart';

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final DatabaseReference petProfilesRef = FirebaseDatabase.instance
        .ref()
        .child('PetProfiles')
        .child(currentUser!.uid);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 86, 99),
      appBar: AppBar(
        title:
            Text('Pet Profile', style: GoogleFonts.lexend(color: Colors.white)),
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
        StreamBuilder(
          stream: petProfilesRef.onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text('An error occurred: ${snapshot.error}',
                      style: GoogleFonts.lexend(color: Colors.white)));
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final petProfilesData = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: petProfilesData.length,
                itemBuilder: (context, index) {
                  final petProfileKey = petProfilesData.keys.elementAt(index);
                  final petProfile =
                      Map<String, dynamic>.from(petProfilesData[petProfileKey]);

                  return GestureDetector(
                    onTap: () {
                      final medicalRecords = petProfile['medicalRecords'] ??
                          {}; // Ensure medical records are available
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MedicalListScreen(
                          petId: petProfileKey,
                          medicalRecords:
                              Map<String, dynamic>.from(medicalRecords as Map),
                        ),
                      ));
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.5),
                          backgroundImage: petProfile['profileImage'] != null
                              ? NetworkImage(petProfile[
                                  'profileImage']) // Load the profile image from Firebase
                              : AssetImage(
                                      'assets/images/questionmark.png') // Default placeholder image
                                  as ImageProvider, // Specify type to handle both
                        ),
                        title: Text(
                          petProfile['petName'] ?? 'Unknown',
                          style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Breed: ${petProfile['breed'] ?? 'N/A'}',
                                style:
                                    GoogleFonts.lexend(color: Colors.white70)),
                            Text('Color: ${petProfile['color'] ?? 'N/A'}',
                                style:
                                    GoogleFonts.lexend(color: Colors.white70)),
                            Text('Sex: ${petProfile['sex'] ?? 'N/A'}',
                                style:
                                    GoogleFonts.lexend(color: Colors.white70)),
                            Text('DOB: ${petProfile['dateOfBirth'] ?? 'N/A'}',
                                style:
                                    GoogleFonts.lexend(color: Colors.white70)),
                            const SizedBox(height: 10),
                            Text(
                              'Tap here to view medical records...',
                              style: GoogleFonts.lexend(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(Iconsax.pet, color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            } else {
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
                      'No pet profiles found. \nAdd one to get started!',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        )
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddPetProfileScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class MedicalListScreen extends StatelessWidget {
  final String petId;
  final Map<String, dynamic> medicalRecords;

  const MedicalListScreen({
    super.key,
    required this.petId,
    required this.medicalRecords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 86, 99),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Medical Records',
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
      body: medicalRecords.isEmpty
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
                    'No medical records found!',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 86, 99),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: medicalRecords.length,
              itemBuilder: (context, index) {
                final recordKey = medicalRecords.keys.elementAt(index);
                final record = medicalRecords[recordKey];

                return Card(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text(
                      "Date: ${record['timestamp'] != null ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(record['timestamp'])) : 'N/A'}",
                      style: GoogleFonts.lexend(),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Complaint: ${record['complaint'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                        Text(
                          "Treatment: ${record['treatment'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                        Text(
                          "Diagnosis: ${record['diagnosis'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                        Text(
                          "Recommendation: ${record['recommendation'] ?? 'N/A'}",
                          style: GoogleFonts.lexend(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
