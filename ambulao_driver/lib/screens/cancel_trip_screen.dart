import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class CancelTripScreen extends StatefulWidget {
  const CancelTripScreen({super.key});

  @override
  State<CancelTripScreen> createState() => _CancelTripScreenState();
}

class _CancelTripScreenState extends State<CancelTripScreen> {
  String? _selectedReason;

  final List<String> _reasons = [
    'Patient no-show',
    'Wrong location',
    'Emergency',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cancel Trip',
          style: TextStyle(
            color: Color(0xFF0A1F44),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you cancelling?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A1F44),
              ),
            ),
            const SizedBox(height: 20),

            // Reason pills
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _reasons.map((r) {
                final sel = _selectedReason == r;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReason = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: sel
                            ? AppTheme.primaryBlue
                            : const Color(0xFFDDE3EE),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      r,
                      style: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF0A1F44),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Warning box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFF9500), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Frequent cancellations may affect your rating and reduce trip access.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B6914),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Keep Trip
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Keep Trip',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Trip
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.criticalRed,
                  side: const BorderSide(
                    color: AppTheme.criticalRed,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Cancel Trip',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
