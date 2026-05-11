import 'package:flutter/material.dart';

/// Animated shimmer card for loading states.
/// Each instance manages its own AnimationController.
class ShimmerCard extends StatefulWidget {
  final double height;
  final EdgeInsets margin;

  const ShimmerCard({
    super.key,
    this.height = 72,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) => Container(
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: const [
              Color(0xFFE8F0EB),
              Color(0xFFCDD8D2),
              Color(0xFFE8F0EB),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(-2.0 + 4.0 * _ac.value, 0),
            end: Alignment(-1.0 + 4.0 * _ac.value, 0),
          ),
        ),
      ),
    );
  }
}
