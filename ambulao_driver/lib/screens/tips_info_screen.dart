import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class TipsInfoScreen extends StatelessWidget {
  const TipsInfoScreen({super.key});

  static const _tips = [
    ('Maintain a High Rating', 'Greet patients warmly, drive smoothly, and confirm destination before starting. Rating above 4.8 gets you priority dispatch.'),
    ('Maximize Earnings with Surge Hours', 'Peak hours are 6–9 AM and 6–9 PM. Going online during these windows earns up to 1.5x the base fare.'),
    ('Keep Documents Up-to-Date', 'Expired documents can lead to account suspension. Check the Documents screen regularly and upload renewals early.'),
    ('Accept More Trips', 'Maintaining an acceptance rate above 80% keeps you eligible for bonuses and Drive Pass benefits.'),
    ('Vehicle Hygiene Matters', 'Patients expect clean, sanitized ambulances. A clean vehicle leads to higher ratings and repeat assignments.'),
    ('Use In-App Navigation', 'Set Google Maps or Waze as your preferred app in Settings. Pre-save hospital locations for faster response.'),
    ('Report Issues Promptly', 'Use the Bug Reporter for app issues and Help & Support for trip disputes. Early reporting speeds resolution.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)), onPressed: () => Navigator.pop(context)),
        title: const Text('Tips & Info', style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _tips.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _TipCard(title: _tips[i].$1, body: _tips[i].$2),
      ),
    );
  }
}

class _TipCard extends StatefulWidget {
  final String title;
  final String body;
  const _TipCard({required this.title, required this.body});
  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _open ? AppTheme.primaryBlue : const Color(0xFFF0F4FF), width: _open ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.lightbulb_outline, color: AppTheme.primaryBlue, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: _open ? AppTheme.primaryBlue : const Color(0xFF0A1F44)))),
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
              ]),
              if (_open) ...[
                const SizedBox(height: 12),
                Text(widget.body, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
