import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TechnicianRatingWidget extends StatefulWidget {
  final String technicianId;
  final double currentRating; // Eita hobe (totalRatingSum / ratingCount)

  const TechnicianRatingWidget({
    super.key,
    required this.technicianId,
    required this.currentRating,
  });

  @override
  State<TechnicianRatingWidget> createState() => _TechnicianRatingWidgetState();
}

class _TechnicianRatingWidgetState extends State<TechnicianRatingWidget> {
  int _selectedRating = 0; // User kon star porjonto select korlo
  bool isSubmitting = false;

  // Rating submit korar function
  Future<void> _submitRating(int rating) async {
    setState(() => isSubmitting = true);

    try {
      DocumentReference techDoc = FirebaseFirestore.instance.collection('technicians').doc(widget.technicianId);

      // Firestore er atomic update use korchi, jate data missing na hoy
      await techDoc.update({
        'totalRatingSum': FieldValue.increment(rating * 1.0), // Je rating dise seta jog hobe
        'ratingCount': FieldValue.increment(1),               // 1 jon barbe
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanks for your rating!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit rating: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Star Selection UI
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int starNumber = index + 1;
            return IconButton(
              onPressed: isSubmitting ? null : () {
                setState(() => _selectedRating = starNumber);
                _submitRating(starNumber); // Click korlei firebase e update hobe
              },
              icon: Icon(
                starNumber <= _selectedRating ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFC65C),
                size: 35,
              ),
            );
          }),
        ),

        // Average Rating Show korar part
        Text(
          "Average: ${widget.currentRating.toStringAsFixed(1)} ⭐",
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}