import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ফায়ারবেস অথেন্টিকেশন
import 'package:shebafinderbdnew/Screens/HomePage.dart';
import 'package:shebafinderbdnew/Screens/RoleSelection.dart';
import 'package:shebafinderbdnew/Screens/auth/userSignup.dart';
import 'package:shebafinderbdnew/Screens/Admin_Screen/admin_dashboard.dart';

class UserLoginScreen extends StatefulWidget {
  final bool isAdmin; // অ্যাডমিন ট্রিকের জন্য
  const UserLoginScreen({super.key, this.isAdmin = false});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  // ইনপুট ফিল্ড কন্ট্রোল করার জন্য
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false; // লোডিং এর জন্য
  bool isPasswordVisible = false; // পাসওয়ার্ড দেখানোর জন্য

  // লগইন লজিক
  void _loginUser() async {
    setState(() => isLoading = true);

    try {
      // ফায়ারবেসে লগইন যাচাই
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // অ্যাডমিন ট্রিক (Temporary)
      if (_emailController.text.trim() == 'admin@gmail.com') {
        if (mounted) {
          // অ্যাডমিন হলে হোম পেজে যাবে না, সরাসরি অ্যাডমিন পেজে যাবে
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()), // পরে আমরা এই পেজ বানাবো
                (route) => false,
          );
        }
      } else {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      String msg = "Login Failed";
      if (e.code == 'user-not-found') {
        msg = "No user found for this email.";
      } else if (e.code == 'wrong-password'){ msg = "Wrong password.";}
      else if (e.code == 'invalid-email') {msg = "Invalid email format.";}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>RoleSelectionScreen()), (route)=>false),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login to your account to continue",
                  style: TextStyle(color: Colors.white54, fontSize: 15),
                ),

                const SizedBox(height: 40),


                _buildTextField(
                  controller: _emailController,
                  hint: "Email Address",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
            

                _buildTextField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isObscure: !isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
            

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFFFFC65C), fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            
                const SizedBox(height: 30),
            

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginUser,
            
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF101D42),
                      disabledBackgroundColor: const Color(0xFF101D42).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFFFC65C), strokeWidth: 2)
                        : const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            
                const SizedBox(height: 25),
            

                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text("OR", style: TextStyle(color: Colors.white54)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
            
                const SizedBox(height: 25),
            

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Google Sign-In coming soon!"), backgroundColor: Colors.grey),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text("G", style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
            

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.white54)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserSignupScreen()));
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Color(0xFFFFC65C), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      autofillHints: const [AutofillHints.email],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFFFC65C)),
        suffixIcon: suffixIcon,
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