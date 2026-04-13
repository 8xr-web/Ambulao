import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _contact(BuildContext context) async {
    final uri = Uri.parse('mailto:privacy@ambulao.in');
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
      _Section('Information We Collect', 'We may collect contact details, booking information, device information, and usage analytics to provide the service.'),
      _Section('How We Use Your Data', 'We use data to dispatch services, communicate updates, provide support, and improve reliability and safety.'),
      _Section('Location Data', 'Location is used to find nearby providers and route assistance. You can control location permissions in your device settings.'),
      _Section('Medical Information', 'If you provide medical details, we use them to improve response quality during emergencies.'),
      _Section('Data Sharing', 'We may share necessary booking and location details with dispatch partners to fulfill your request.'),
      _Section('Data Retention', 'We retain data as long as needed for service operations, legal obligations, and dispute resolution.'),
      _Section('Your Rights', 'You may request access, correction, or deletion of certain data as permitted by law.'),
      _Section('Contact Us', 'For privacy questions or requests, contact our privacy team.'),
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
          AppStrings.privacyPolicy,
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
                AppStrings.contactPrivacy,
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

