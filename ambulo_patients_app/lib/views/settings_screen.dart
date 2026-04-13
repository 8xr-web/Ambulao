import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/app_strings.dart';
import 'change_phone_number_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';
import 'linked_documents_screen.dart';
import '../core/transitions.dart';
import 'package:flutter_hello_world/localisation/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bookingAlerts = true;
  bool _emergencyNotifs = true;
  bool _promoUpdates = false;
  bool _locationAccess = true;
  bool _biometricLogin = false;

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
        title: Text(AppLocalizations.of(context)!.settings, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ACCOUNT
            _sectionLabel('ACCOUNT'),
            _settingCard([
              _arrowRow(AppStrings.changePhoneNumber, onTap: () {
                Navigator.of(context).push(SmoothPageRoute(page: const ChangePhoneNumberScreen()));
              }),
              _divider(),
              _arrowRow('Linked Documents', onTap: () => Navigator.push(context, SmoothPageRoute(page: const LinkedDocumentsScreen()))),
            ]),

            // NOTIFICATIONS
            _sectionLabel('NOTIFICATIONS'),
            _settingCard([
              _toggleRow('Booking Alerts', _bookingAlerts, (v) => setState(() => _bookingAlerts = v)),
              _divider(),
              _toggleRow('Emergency Contact Notifications', _emergencyNotifs, (v) => setState(() => _emergencyNotifs = v)),
              _divider(),
              _toggleRow('Promotional Updates', _promoUpdates, (v) => setState(() => _promoUpdates = v)),
            ]),

            // PRIVACY & SECURITY
            _sectionLabel('PRIVACY & SECURITY'),
            _settingCard([
              _toggleRow('Location Access', _locationAccess, (v) => setState(() => _locationAccess = v)),
              _divider(),
              _toggleRow('Face ID / Fingerprint Login', _biometricLogin, (v) => setState(() => _biometricLogin = v)),
              _divider(),
              _arrowRow('Delete Account', isDestructive: true, onTap: () => _confirmDelete()),
            ]),

            // SUPPORT
            _sectionLabel('SUPPORT'),
            _settingCard([
              _arrowRow(AppStrings.helpSupport, onTap: () {
                Navigator.of(context).push(SmoothPageRoute(page: const HelpSupportScreen()));
              }),
              _divider(),
              _arrowRow(AppStrings.rateTheApp, onTap: _rateApp),
              _divider(),
              _arrowRow(AppStrings.termsConditions, onTap: () {
                Navigator.of(context).push(SmoothPageRoute(page: const TermsAndConditionsScreen()));
              }),
              _divider(),
              _arrowRow(AppStrings.privacyPolicy, onTap: () {
                Navigator.of(context).push(SmoothPageRoute(page: const PrivacyPolicyScreen()));
              }),
              _divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('App Version', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  Text('1.0.0', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                ]),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Text(text, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
  );

  Widget _settingCard(List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Column(children: children),
  );

  Widget _divider() => const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF0F2F5));

  Widget _arrowRow(String label, {String? value, bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: isDestructive ? const Color(0xFFEF4444) : AppColors.textPrimary, fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal))),
          if (value != null) ...[
            Text(value, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 13)),
            const SizedBox(width: 6),
          ],
          if (!isDestructive) const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 18),
        ]),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primaryBlue, activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.4)),
      ]),
    );
  }

  Future<void> _rateApp() async {
    // Replace these IDs when live.
    const iosStore = 'itms-apps://itunes.apple.com/app/idXXXXXXXXX';
    const iosWeb = 'https://itunes.apple.com/app/idXXXXXXXXX';
    const androidStore = 'market://details?id=com.ambulao.app';
    const androidWeb = 'https://play.google.com/store/apps/details?id=com.ambulao.app';

    final storeUri = Uri.parse(Platform.isIOS ? iosStore : androidStore);
    final webUri = Uri.parse(Platform.isIOS ? iosWeb : androidWeb);

    if (await canLaunchUrl(storeUri)) {
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      return;
    }
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Unable to open store'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 16),
          const Text('Delete Account?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
          const SizedBox(height: 8),
          const Text('This will permanently delete your account and all booking history. This action cannot be undone.',
            textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7A99), fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0),
            child: const Text('Delete My Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          )),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }
}
