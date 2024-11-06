import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

                  return Card(
                    elevation: 4,
                    color: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
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
                              style: GoogleFonts.lexend(color: Colors.white70)),
                          Text('Color: ${petProfile['color'] ?? 'N/A'}',
                              style: GoogleFonts.lexend(color: Colors.white70)),
                          Text('Sex: ${petProfile['sex'] ?? 'N/A'}',
                              style: GoogleFonts.lexend(color: Colors.white70)),
                          Text(
                              'Date of Birth: ${petProfile['dateOfBirth'] ?? 'N/A'}',
                              style: GoogleFonts.lexend(color: Colors.white70)),
                        ],
                      ),
                      trailing: const Icon(Iconsax.pet, color: Colors.white),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  'No pet profiles found. Add one to get started!',
                  style: GoogleFonts.lexend(color: Colors.white),
                  textAlign: TextAlign.center,
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
