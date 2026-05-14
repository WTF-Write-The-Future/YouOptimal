import 'package:flutter/material.dart';

class CityMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const CityMetricChip({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF485759)),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: const TextStyle(fontFamily: 'SFPro', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF485759)),
          ),
        ],
      ),
    );
  }
}