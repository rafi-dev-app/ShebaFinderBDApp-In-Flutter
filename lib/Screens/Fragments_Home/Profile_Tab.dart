import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shebafinderbdnew/Screens/RoleSelection.dart';
import 'package:shebafinderbdnew/Screens/auth/UserLoginScreen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // উপরের গ্র্যাডিয়েন্ট ব্যাকগ্রাউন্ড
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // প্রোফাইল ছবি
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFC65C), width: 3)),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 60, color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Mehedi Hasan Rafi", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text("mehedi@gmail.com", style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 10),
                    // Edit Profile বাটন
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC65C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text("Edit Profile", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // সেটিংস মেনু
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(Icons.my_location_outlined, "Saved Addresses"),
                  _buildMenuItem(Icons.payment_outlined, "Payment Methods"),
                  _buildMenuItem(Icons.notifications_none_outlined, "Notifications"),
                  _buildMenuItem(Icons.info_outline, "About Us"),
                  _buildMenuItem(Icons.privacy_tip_outlined, "Privacy Policy"),

                  const Divider(color: Colors.white10, height: 40),

                  // লগআউট বাটন
                  ListTile(

                      onTap: () async {
                        if (mounted) await Future.delayed(const Duration(milliseconds: 100));
                        // ১. ফায়ারবেস থেকে সরাসরি লগআউট করা হচ্ছে
                        await FirebaseAuth.instance.signOut();

                        if (context.mounted) {
                          // ২. ইউজারকে মেসেজ দেখানো
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // ৩. অ্যাপের সব পেজ মুছে স্প্ল্যাশ/রোল সিলেকশন পেজে নিয়ে যাওয়া
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()), // আপনার রোল সিলেকশন পেজের নাম ঠিক করে দেবেন
                                (route) => false,
                          );
                        }
                      },

                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.logout, color: Colors.redAccent),
                    ),
                    title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFFFFC65C)),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
    );
  }
}