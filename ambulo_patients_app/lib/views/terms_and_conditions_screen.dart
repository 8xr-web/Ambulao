import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  Future<void> _contact(BuildContext context) async {
    final uri = Uri.parse('mailto:legal@ambulao.in');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Unable to open mail app'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sections = [
      _Section('Acceptance of Terms', 'By using Ambulao, you agree to these Terms & Conditions. If you do not agree, please do not use the service.'),
      _Section('Use of Service', 'You must provide accurate information and use the service responsibly. Misuse may result in suspension.'),
      _Section('Booking & Cancellation Policy', 'Bookings may be cancelled during the search phase. Fees and policies may vary by provider and city.'),
      _Section('Payment Terms', 'Applicable charges will be shown before confirmation. Some services may require advance payment.'),
      _Section('Emergency Services Disclaimer', 'Ambulao facilitates dispatch and coordination. Response times can vary due to traffic, availability, and local conditions.'),
      _Section('Privacy & Data Usage', 'We collect and use data to provide and improve the service. Please refer to the Privacy Policy for details.'),
      _Section('Liability Limitations', 'To the extent permitted by law, Ambulao is not liable for indirect or consequential damages arising from service use.'),
      _Section('Contact Information', 'For questions regarding these terms, contact our legal team.'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
        ),
        title: const Text(
          AppStrings.termsConditions,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.lastUpdatedMarch2026, style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...sections.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.heading, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(s.body, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7A99), height: 1.45)),
                ],
              ),
            )),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _contact(context),
              child: const Text(
                AppStrings.contactLegal,
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section {
  final String heading;
  final String body;
  const _Section(this.heading, this.body);
}

