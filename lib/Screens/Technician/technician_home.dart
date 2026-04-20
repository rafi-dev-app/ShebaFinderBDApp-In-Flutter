import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shebafinderbdnew/Screens/Technician/fragments/Booking_fragments.dart';
import 'package:shebafinderbdnew/Screens/Technician/fragments/Earning_fragments.dart';
import 'package:shebafinderbdnew/Screens/Technician/fragments/profile_fragments.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int _currentIndex = 0;


  final List<Widget> _pages = [
    const TechDashboardFragment(),
    const TechBookings(),
    const TechEarnings(),
    const TechProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFFFFC65C),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_outlined),
            activeIcon: Icon(Icons.home_work),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: "Earnings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}


class TechDashboardFragment extends StatelessWidget {
  const TechDashboardFragment({super.key});


  Future<void> _toggleStatus(String uid, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('technicians')
        .doc(uid)
        .update({'isAvailable': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const Center(child: Text("Login Required", style: TextStyle(color: Colors.white)));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('technicians').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC65C)));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No Data Found", style: TextStyle(color: Colors.white)));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isAvailable = data['isAvailable'] ?? false;
        String techName = data['name'] ?? "Technician";

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Welcome Back,", style: TextStyle(color: Colors.white54, fontSize: 14)),
                          const SizedBox(height: 5),
                          Text(techName,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    _buildNotificationIcon(),
                  ],
                ),

                const SizedBox(height: 25),

                // --- Status Card (Firebase Toggle) ---
                _buildStatusToggle(uid, isAvailable),

                const SizedBox(height: 30),

                // --- Quick Stats ---
                Row(
                  children: [
                    Expanded(child: _buildQuickStat(Icons.pending_actions, "New Jobs", "3", Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildQuickStat(Icons.check_circle_outline, "Completed", "45", Colors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildQuickStat(Icons.star_outline, "Rating",
                        (data['ratingCount'] > 0 ? (data['totalRatingSum'] / data['ratingCount']).toStringAsFixed(1) : "0.0"),
                        Colors.orange)),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Recent Bookings ---
                const Text("Recent Bookings", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildBookingItem("Rahim Uddin", "Electrician", "Pending", Colors.orange),
                _buildBookingItem("Karim Bhai", "Plumber", "Accepted", Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatusToggle(String uid, bool isAvailable) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAvailable
              ? [const Color(0xFFFFC65C), Colors.orange]
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your Status", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              Text(isAvailable ? "Available Now" : "Currently Busy",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Switch(
            value: isAvailable,
            activeColor: Colors.greenAccent,
            onChanged: (val) => _toggleStatus(uid, isAvailable),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.notifications_none, color: Color(0xFFFFC65C)),
    );
  }

  Widget _buildQuickStat(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBookingItem(String name, String service, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white54)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(service, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}