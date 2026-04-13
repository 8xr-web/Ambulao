import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import 'faq_screen.dart';
import 'customer_support_chat_screen.dart';
import '../core/transitions.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _openUrl(BuildContext context, Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Unable to open'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          AppStrings.helpSupport,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A6FE8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.helpHeroTitle, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(AppStrings.helpHeroSubtitle, style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _optionCard(
              context,
              icon: Icons.phone_in_talk_outlined,
              title: AppStrings.callSupport,
              subtitle: AppStrings.callSupportSubtitle,
              onTap: () => _openUrl(context, Uri.parse('tel:1800XXXXXXX')),
            ),
            const SizedBox(height: 12),
            _optionCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: AppStrings.liveChat,
              subtitle: AppStrings.liveChatSubtitle,
              onTap: () => Navigator.of(context).push(SmoothPageRoute(page: const CustomerSupportChatScreen())),
            ),
            const SizedBox(height: 12),
            _optionCard(
              context,
              icon: Icons.email_outlined,
              title: AppStrings.emailUs,
              subtitle: 'support@ambulao.in',
              onTap: () => _openUrl(context, Uri.parse('mailto:support@ambulao.in')),
            ),
            const SizedBox(height: 12),
            _optionCard(
              context,
              icon: Icons.warning_amber_outlined,
              title: AppStrings.emergencyHelpline,
              subtitle: AppStrings.emergencyHelplineSubtitle,
              destructive: true,
              onTap: () => _openUrl(context, Uri.parse('tel:108')),
            ),
            const SizedBox(height: 12),
            _optionCard(
              context,
              icon: Icons.help_outline,
              title: AppStrings.faq,
              subtitle: AppStrings.faqSubtitle,
              onTap: () => Navigator.of(context).push(SmoothPageRoute(page: const FaqScreen())),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final iconColor = destructive ? const Color(0xFFEF4444) : AppColors.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
}

