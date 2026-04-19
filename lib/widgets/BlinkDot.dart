// ব্লিংকিং অ্যানিমেশনের জন্য আলাদা উইজেট
import 'package:flutter/material.dart';
class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;

  const BlinkingDot({
    super.key,
    required this.color,
    this.size = 8.0,
  });

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // অ্যানিমেশন কন্ট্রোলার: ১ সেকেন্ড সময় ধরে হবে এবং বারবার হবে (repeat)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // অ্যানিমেশন ভ্যালু: ০ থেকে ১ এর মধ্যে চলে
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // মেমোরি লিক এড়ানোর জন্য
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // অ্যানিমেশন যত এগোবে, Opacity ১ থেকে ০.১ এ নেমে আসবে (ম্লান হয়ে যাবে)
        return Opacity(
          opacity: 1.0 - (_animation.value * 0.8),
          child: child,
        );
      },
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          // একটু আলো ছড়ানোর জন্য boxShadow দেওয়া হয়েছে
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}