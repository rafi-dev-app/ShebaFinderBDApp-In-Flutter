
// ==========================================
// ২. পেন্ডিং রিকোয়েস্ট পেজ (Approve Button Fix + Image Show)
// ==========================================
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class  PendingRequests extends StatelessWidget {
  const PendingRequests();

  // Function ta ke baire likha holo jeno properly kaj kore
  void _approveTechnician(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('technicians').doc(docId).update({
        'status': 'approved',
        'isAvailable': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Technician Approved Successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to approve: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _rejectTechnician(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('technicians').doc(docId).update({
        'status': 'rejected',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Technician Rejected."), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('technicians').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC65C)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pending requests right now.", style: TextStyle(color: Colors.white54)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // Base64 Image decode korar logic
            Uint8List? imageBytes;
            if (data['imageBase64'] != null && data['imageBase64'].toString().isNotEmpty) {
              imageBytes = base64Decode(data['imageBase64']);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Image Show kora hocche
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: ClipOval(
                          child: imageBytes != null
                              ? Image.memory(imageBytes, fit: BoxFit.cover, width: 50, height: 50)
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'] ?? "Unknown", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("${data['category']} |Experience ${data['experience']}", style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),
                  Text("Address: ${data['address']}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 5),
                  Text("Phone: ${data['phone']}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Reject Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectTechnician(context, doc.id), // Function call
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Reject", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Approve Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approveTechnician(context, doc.id), // Function call
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified, size: 18),
                              SizedBox(width: 5),
                              Text("Approve", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}