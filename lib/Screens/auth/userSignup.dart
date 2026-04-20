import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shebafinderbdnew/Screens/auth/UserLoginScreen.dart';

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool agreeToTerms = false;


  void _signupUser() async {

    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter your name", Colors.redAccent);
      return;
    }
    if (_emailController.text.trim().isEmpty || !_emailController.text.trim().contains('@')) {
      _showSnackBar("Please enter a valid email", Colors.redAccent);
      return;
    }
    if (_phoneController.text.trim().isEmpty || _phoneController.text.trim().length < 11) {
      _showSnackBar("Please enter a valid phone number", Colors.redAccent);
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _showSnackBar("Password must be at least 6 characters", Colors.redAccent);
      return;
    }
    if (!agreeToTerms) {
      _showSnackBar("Please agree to the Terms and Conditions", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    try {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );


      await userCredential.user?.updateDisplayName(_nameController.text.trim());


      if (mounted) {
        _showSnackBar("Account created successfully!", Colors.green);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserLoginScreen()),
              (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      String msg = "Signup Failed";
      if (e.code == 'email-already-in-use') {
        msg = "This email is already registered. Please login.";
      } else if (e.code == 'weak-password') {
        msg = "Password is too weak. Use at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        msg = "Invalid email format.";
      } else if (e.code == 'network-request-failed') {
        msg = "No internet connection. Please try again.";
      }
      if (mounted) _showSnackBar(msg, Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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


              _buildTextField(
                controller: _nameController,
                hint: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),


              _buildTextField(
                controller: _emailController,
                hint: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),


              _buildTextField(
                controller: _phoneController,
                hint: "Phone (01XXXXXXXXX)",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),


              _buildTextField(
                controller: _passwordController,
                hint: "Password (min 6 characters)",
                icon: Icons.lock_outline,
                isObscure: !isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: () {
                    setState(() => isPasswordVisible = !isPasswordVisible);
                  },
                ),
              ),

              const SizedBox(height: 15),


              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: agreeToTerms,
                      onChanged: (val) {
                        setState(() => agreeToTerms = val ?? false);
                      },
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

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signupUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC65C),
                    disabledBackgroundColor: const Color(0xFFFFC65C).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2)
                      : const Text(
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


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.white54)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
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