import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text("Please login to see bookings", style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Bookings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('bookingTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC65C)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 70, color: Colors.white24),
                  SizedBox(height: 15),
                  Text("No Bookings Found!", style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String status = data['status'] ?? 'Pending';
              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'Accepted':
                  statusColor = Colors.blueAccent;
                  statusIcon = Icons.thumb_up_alt_outlined;
                  break;
                case 'In Progress':
                  statusColor = Colors.purpleAccent;
                  statusIcon = Icons.run_circle_outlined;
                  break;
                case 'Completed':
                  statusColor = Colors.greenAccent;
                  statusIcon = Icons.verified_outlined;
                  break;
                case 'Rejected':
                case 'Cancelled':
                  statusColor = Colors.redAccent;
                  statusIcon = Icons.block_flipped;
                  break;
                default: // Pending
                  statusColor = const Color(0xFFFFC65C);
                  statusIcon = Icons.hourglass_empty_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    collapsedIconColor: Colors.white54,
                    iconColor: statusColor,
                    // টাইল এর মূল অংশ
                    title: Text(
                      data['techName'] ?? "Technician",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),

                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            const Divider(color: Colors.white10),
                            _buildDetailRow(Icons.settings_suggest_outlined, "Service", data['techCategory'] ?? 'N/A'),
                            _buildDetailRow(Icons.event_available, "Date", data['date'] ?? 'N/A'),
                            _buildDetailRow(Icons.alarm, "Time", data['time'] ?? 'N/A'),
                            _buildDetailRow(Icons.location_on_outlined, "Address", data['userAddress'] ?? 'No Address Provided'),
                            if (data['problemDescription'] != null)
                              _buildDetailRow(Icons.description_outlined, "Problem", data['problemDescription']),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFFC65C)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  TextSpan(text: value, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}