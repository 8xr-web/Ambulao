import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class DrivePassScreen extends StatelessWidget {
  const DrivePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)), onPressed: () => Navigator.pop(context)),
        title: const Text('Drive Pass', style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0040A0), AppTheme.primaryBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(children: [
                const Icon(Icons.card_membership, color: Colors.white, size: 56),
                const SizedBox(height: 16),
                const Text('AMBULAO Drive Pass', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(50)),
                  child: const Text('Active — Gold Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 16),
                const Text('Valid until: 31 Dec 2026', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 28),
            const Align(alignment: Alignment.centerLeft,
              child: Text('Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)))),
            const SizedBox(height: 16),
            ...[
              ('Priority dispatch for emergency trips', Icons.bolt),
              ('Surge bonus eligibility (1.5x)', Icons.trending_up),
              ('Dedicated driver support line', Icons.headset_mic),
              ('Monthly performance rewards', Icons.emoji_events),
              ('Free vehicle inspection every 3 months', Icons.car_repair),
            ].map((b) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(10)),
                  child: Icon(b.$2, color: AppTheme.primaryBlue, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Text(b.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44)))),
              ]),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upgrade flow coming soon!'), behavior: SnackBarBehavior.floating)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                child: const Text('Upgrade to Platinum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
