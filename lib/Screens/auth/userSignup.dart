import 'package:flutter/material.dart';
import 'package:shebafinderbdnew/Screens/auth/UserLoginScreen.dart';

class UserSignupScreen extends StatelessWidget {
  const UserSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create your\naccount",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              // নাম ইনপুট
              _buildTextField("Full Name", Icons.person_outline),
              const SizedBox(height: 20),

              // ইমেইল ইনপুট
              _buildTextField("Email", Icons.email_outlined),
              const SizedBox(height: 20),

              // ফোন ইনপুট
              _buildTextField("Phone", Icons.phone_outlined),
              const SizedBox(height: 20),

              // পাসওয়ার্ড ইনপুট
              _buildTextField("Password", Icons.lock_outline, isObscure: true),

              const SizedBox(height: 15),

              // টার্মস অ্যান্ড কন্ডিশন চেকবক্স (আপনার রেফারেন্স ইমেজ অনুযায়ী)
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: false, // ডেমোর জন্য সবসময় চেক থাকবে
                      onChanged: (val) {},
                      activeColor: const Color(0xFFFFC65C),
                      checkColor: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "I agree to the Terms and Conditions",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // সাইনআপ বাটন (গোল্ডেন কালার)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // সাইনআপ সফল হলে লগইন পেজে পাঠিয়ে দেবে
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC65C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ইনপুট ফিল্ড বানানোর কমন মেথড (লগইন এর মতোই)
  Widget _buildTextField(String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC65C)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFC65C), width: 1.5),
        ),
      ),
    );
  }
}