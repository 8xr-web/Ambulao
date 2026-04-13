import 'package:flutter/material.dart';

class LocationSearchBar extends StatelessWidget {
  final String hintText;
  final bool enabled;
  final VoidCallback? onTap;

  const LocationSearchBar({
    super.key,
    required this.hintText,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          enabled: enabled,
          onTap: enabled
              ? onTap
              : null, // Forward tap if enabled is true but used as TextField
          // If enabled is false, GestureDetector handles the tap.
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
