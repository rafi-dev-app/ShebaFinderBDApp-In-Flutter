import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shebafinderbdnew/Screens/Technician/technician_details.dart';
import 'package:shebafinderbdnew/Screens/categories_technician.dart';
import 'package:shebafinderbdnew/Screens/Fragments_Home/booking_list.dart';
import 'package:shebafinderbdnew/Screens/Fragments_Home/Profile_Tab.dart';
import 'package:shebafinderbdnew/Screens/Fragments_Home/support_Tab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const _MainDashboard(),
    const BookingListScreen(),
    const SupportScreen(),
    const UserProfileScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic_outlined), label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

class _MainDashboard extends StatelessWidget {
  const _MainDashboard();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.orange),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Location", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text("Uttara, Dhaka", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search services",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Categories
            const Text("Categories", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),

            SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _categoryItem(Icons.electric_bolt, "Electrician", context),
                  _categoryItem(Icons.plumbing, "Plumber", context),
                  _categoryItem(Icons.chair, "Carpenter", context),
                  _categoryItem(Icons.format_paint, "Painter", context),
                  _categoryItem(Icons.clean_hands, "Cleaner", context),
                  _categoryItem(Icons.military_tech, "Mestory", context),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Technicians
            const Text("Top Rated Technicians", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('technicians')
                  .where('status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No technicians found", style: TextStyle(color: Colors.white54));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {

                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;


                    double totalRatingSum = (data['totalRatingSum'] ?? 0.0).toDouble();
                    int ratingCount = (data['ratingCount'] ?? 0).toInt();
                    double averageRating = ratingCount > 0 ? (totalRatingSum / ratingCount) : 0.0;


                    Uint8List? imageBytes;
                    if (data['imageBase64'] != null && data['imageBase64'].toString().isNotEmpty) {
                      imageBytes = base64Decode(data['imageBase64']);
                    }

                    return _technicianCard(
                      context,
                      data, // Shob information ekhane ace
                      doc.id,
                      imageBytes, // Image preview er jonno
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

Widget _categoryItem(IconData icon, String label, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryTechnicianScreen(categoryName: label),
        ),
      );
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.orange),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

Widget _technicianCard(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
    Uint8List? imageBytes,
    ) {

  String name = data['name'] ?? "Unknown";
  String category = data['category'] ?? "General";
  double totalRatingSum = (data['totalRatingSum'] ?? 0.0).toDouble();
  int ratingCount = (data['ratingCount'] ?? 0).toInt();
  double averageRating = ratingCount > 0 ? (totalRatingSum / ratingCount) : 0.0;
  bool isAvailable = data['isAvailable'] ?? false;

  return InkWell(
    onTap: () {
      // ✅ এখন শুধু docId পাঠাচ্ছি, StreamBuilder বাকিটা নিজেই আনবে
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TechnicianDetailScreen(docId: docId),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(15),
            ),
            child: imageBytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            )
                : const Icon(Icons.person, color: Colors.white54, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 14),
                          SizedBox(width: 3),
                          Text("Verified", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(category, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isAvailable ? "Available" : "Busy",
                        style: TextStyle(
                          color: isAvailable ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        ],
      ),
    ),
  );
}