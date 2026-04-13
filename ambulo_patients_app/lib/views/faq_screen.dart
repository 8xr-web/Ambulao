import 'package:flutter/material.dart';
import '../core/theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      appBar: AppBar(
        title: const Text('FAQs', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFaqItem(
              'How do I cancel a booking?',
              'You can cancel a booking within 2 minutes of confirming. Go to your active trip and tap "Cancel Trip." Cancellations after 2 minutes may incur a small fee.',
            ),
            _buildFaqItem(
              'What if the driver doesn\'t arrive?',
              'If your driver hasn\'t arrived within the estimated time, please call the driver directly using the call button. If unreachable, contact our support at +91 8186960072.',
            ),
            _buildFaqItem(
              'How is the fare calculated?',
              'Fares are calculated based on distance, time, and ambulance type. The estimated fare is shown before you confirm the booking.',
            ),
            _buildFaqItem(
              'What payment methods are accepted?',
              'We accept Cash and UPI payments. Select your preferred method before confirming the booking.',
            ),
            _buildFaqItem(
              'What is BLS vs ALS ambulance?',
              'BLS (Basic Life Support) ambulances are equipped for non-critical emergencies. ALS (Advanced Life Support) ambulances carry advanced equipment and trained paramedics for critical cases.',
            ),
            _buildFaqItem(
              'How do I get a trip receipt?',
              'Your trip receipt is automatically saved in your trip history. Go to Profile → Trip History → select the trip → view receipt.',
            ),
            _buildFaqItem(
              'Is AMBULAO available 24/7?',
              'Yes. AMBULAO operates 24 hours a day, 7 days a week across Hyderabad.',
            ),
            _buildFaqItem(
              'What areas does AMBULAO cover?',
              'Currently available across all of Hyderabad and surrounding areas in Telangana.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(answer, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
