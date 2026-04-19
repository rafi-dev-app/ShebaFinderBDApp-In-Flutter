import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Help & Support", style: TextStyle(color: Colors.white, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC65C).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, size: 60, color: Color(0xFFFFC65C)),
                ),
                const SizedBox(height: 20),
                const Text("How can we help you?", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Our team is here to support you 24/7", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),

               SizedBox(height: 40,),

                _buildQuickAction(context, Icons.call_outlined, "Call Us", "Speak directly to our team"),
                const SizedBox(height: 15),
                _buildQuickAction(context, Icons.email_outlined, "Email Us", "support@shebafinder.com"),
                const SizedBox(height: 15),
                _buildQuickAction(context, Icons.chat_outlined, "Live Chat", "Chat with an active agent"),
            
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title feature coming soon"), backgroundColor: const Color(0xFFFFC65C)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 50, width: 50,
                  decoration: BoxDecoration(color: const Color(0xFFFFC65C).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: const Color(0xFFFFC65C)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}