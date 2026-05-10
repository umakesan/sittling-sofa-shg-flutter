import 'package:flutter/material.dart';

class WarningPanel extends StatelessWidget {
  final List<String> warnings;

  const WarningPanel({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: Border.all(color: const Color(0xFFFFE082)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 6),
              Text(
                '${warnings.length} ${warnings.length == 1 ? 'warning' : 'warnings'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• $w',
                style: const TextStyle(color: Color(0xFF92400E), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
