import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shebafinderbdnew/Screens/RoleSelection.dart';

class TechProfile extends StatelessWidget {
  const TechProfile({super.key});


  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.green,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
            (route) => false,

      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('technicians')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC65C)));
          }

          var userData = snapshot.data;
          String name = userData?['name'] ?? "No Name";
          String category = userData?['category'] ?? "Technician";
          String? base64Image = userData?['imageBase64'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFF1E293B),
                  backgroundImage: (base64Image != null && base64Image.isNotEmpty)
                      ? MemoryImage(base64Decode(base64Image))
                      : null,
                  child: base64Image == null
                      ? const Icon(Icons.person, size: 55, color: Colors.white24)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(category, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 30),

                _buildProfileOption(Icons.person_outline, "Edit Profile"),
                _buildProfileOption(Icons.lock_outline, "Change Password"),
                _buildProfileOption(Icons.help_outline, "Help & Support"),
                _buildProfileOption(Icons.info_outline, "About App"),

                const Spacer(),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFC65C)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: const Color(0xFF1E293B),
      ),
    );
  }
}