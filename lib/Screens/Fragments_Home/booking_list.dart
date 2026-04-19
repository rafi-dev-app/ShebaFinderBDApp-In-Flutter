import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // বর্তমান লগইন করা ইউজারের ID নিচ্ছি
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // যদি কোনো কারণে ইউজার লগইন না থাকে
    if (currentUserId == null) {
      return const Center(
        child: Text("Please login to see bookings", style: TextStyle(color: Colors.white54)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Bookings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // শুধুমাত্র আমার বুকিংগুলো ফিল্টার করে আনছি
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('bookingTime', descending: true) // নতুন বুকিং আগে দেখাবে
            .snapshots(),
        builder: (context, snapshot) {

          // ✅ ১. এরর চেক (ইনডেক্স এরর হলে এখানে ধরা পড়বে)
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ✅ ২. লোডিং চেক
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC65C))
            );
          }

          // ✅ ৩. ডেটা খালি কিনা চেক
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, size: 80, color: Colors.white24),
                  SizedBox(height: 15),
                  Text("No Bookings Yet!", style: TextStyle(color: Colors.white54, fontSize: 18)),
                ],
              ),
            );
          }

          // ✅ ৪. ডেটা পেলে লিস্ট দেখানো
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // ছবি ডিকোড করা হচ্ছে
              Uint8List? imageBytes;
              if (data['techImageBase64'] != null && data['techImageBase64'].isNotEmpty) {
                try {
                  imageBytes = base64Decode(data['techImageBase64']);
                } catch (e) {
                  imageBytes = null;
                }
              }

              // বুকিং এর স্ট্যাটাস অনুযায়ী কালার দেখাবে
              Color statusColor = data['status'] == 'Pending' ? Colors.orange :
              data['status'] == 'Accepted' ? Colors.green : Colors.red;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // টেকনিশিয়ানের ছবি
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(15),
                        image: imageBytes != null
                            ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover)
                            : null,
                      ),
                      child: imageBytes == null
                          ? const Icon(Icons.person, color: Colors.white54, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 15),

                    // টেকনিশিয়ানের তথ্য
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['techName'] ?? "Unknown Technician",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['techCategory'] ?? "Service",
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          // বুকিং স্ট্যাটাস ব্যাজ
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              data['status'] ?? "Pending",
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // সময়
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.access_time, color: Colors.white24, size: 16),
                        const SizedBox(height: 5),
                        Text(
                          _formatDate(data['bookingTime'] ?? ""),
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ডেট ফরমেট করার ছোট্ট হেল্পার মেথড
  String _formatDate(String isoString) {
    if (isoString.isEmpty) return "";
    DateTime dt = DateTime.parse(isoString);
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}