import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TechnicianRatingWidget extends StatefulWidget {
  final String technicianId;

  const TechnicianRatingWidget({
    super.key,
    required this.technicianId,
  });

  @override
  State<TechnicianRatingWidget> createState() => _TechnicianRatingWidgetState();
}

class _TechnicianRatingWidgetState extends State<TechnicianRatingWidget> {
  int _selectedRating = 0;
  bool isSubmitting = false;
  bool hasAlreadyRated = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyRated();
  }


  Future<void> _checkIfAlreadyRated() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot ratingDoc = await FirebaseFirestore.instance
        .collection('technicians')
        .doc(widget.technicianId)
        .collection('ratings')
        .doc(user.uid)
        .get();

    if (mounted && ratingDoc.exists) {
      setState(() {
        hasAlreadyRated = true;
        _selectedRating = (ratingDoc.data() as Map<String, dynamic>)['rating'] ?? 0;
      });
    }
  }


  Future<void> _submitRating(int rating) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to rate"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => isSubmitting = true);

    try {
      DocumentReference techDoc = FirebaseFirestore.instance
          .collection('technicians')
          .doc(widget.technicianId);

      DocumentReference ratingDoc = techDoc.collection('ratings').doc(user.uid);


      DocumentSnapshot existingRating = await ratingDoc.get();

      if (existingRating.exists) {

        int oldRating = (existingRating.data() as Map<String, dynamic>)['rating'];
        int diff = rating - oldRating;

        await Future.wait([

          ratingDoc.set({
            'rating': rating,
            'ratedAt': FieldValue.serverTimestamp(),
            'userEmail': user.email,
          }),

          techDoc.update({
            'totalRatingSum': FieldValue.increment(diff * 1.0),

          }),
        ]);
      } else {
        await Future.wait([

          ratingDoc.set({
            'rating': rating,
            'ratedAt': FieldValue.serverTimestamp(),
            'userEmail': user.email,
          }),

          techDoc.update({
            'totalRatingSum': FieldValue.increment(rating * 1.0),
            'ratingCount': FieldValue.increment(1),
          }),
        ]);
      }

      if (mounted) {
        setState(() {
          hasAlreadyRated = true;
          _selectedRating = rating;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanks for your rating! ⭐"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rating failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC65C).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [

          Text(
            hasAlreadyRated ? "Your Rating" : "Rate this Technician",
            style: TextStyle(
              color: hasAlreadyRated ? Colors.white54 : const Color(0xFFFFC65C),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              int starNumber = index + 1;
              return IconButton(
                onPressed: isSubmitting ? null : () {
                  setState(() => _selectedRating = starNumber);
                  _submitRating(starNumber);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    starNumber <= _selectedRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    key: ValueKey(starNumber <= _selectedRating),
                    color: const Color(0xFFFFC65C),
                    size: 40,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),


          if (hasAlreadyRated)
            Text(
              "You rated $_selectedRating out of 5 ⭐",
              style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w500),
            )
          else if (isSubmitting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Color(0xFFFFC65C), strokeWidth: 2),
            )
          else
            const Text(
              "Tap a star to rate",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
        ],
      ),
    );
  }
}