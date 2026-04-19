
// ==========================================
// ৪. প্রোফাইল
// ==========================================
import 'package:flutter/material.dart';
class TechProfile extends StatelessWidget {
  const TechProfile();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white54),
            ),
            const SizedBox(height: 15),
            const Text("Technician Name", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Electrician", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 30),

            _buildProfileOption(Icons.person_outline, "Edit Profile"),
            _buildProfileOption(Icons.lock_outline, "Change Password"),
            _buildProfileOption(Icons.help_outline, "Help & Support"),
            _buildProfileOption(Icons.info_outline, "About App"),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Back to login/registration
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFC65C)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: const Color(0xFF1E293B),
      ),
    );
  }
}