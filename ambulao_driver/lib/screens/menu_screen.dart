import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/wallet_screen.dart';
import 'package:ambulao_driver/screens/profile_screen.dart';
import 'package:ambulao_driver/screens/vehicles_screen.dart';
import 'package:ambulao_driver/screens/documents_screen.dart';
import 'package:ambulao_driver/screens/insurance_screen.dart';
import 'package:ambulao_driver/screens/settings_screen.dart';
import 'package:ambulao_driver/screens/help_support_screen.dart';
import 'package:ambulao_driver/screens/login_screen.dart';
import 'package:ambulao_driver/screens/drive_pass_screen.dart';
import 'package:ambulao_driver/screens/tax_info_screen.dart';
import 'package:ambulao_driver/screens/tips_info_screen.dart';
import 'package:ambulao_driver/screens/bug_reporter_screen.dart';
import 'package:ambulao_driver/screens/bank_details_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Driver profile card
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'SR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Syed Rayan Hussaini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0A1F44),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'View Profile',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // MANAGE section
              _buildSectionTitle('MANAGE'),
              const SizedBox(height: 10),
              _buildMenuCard([
                _MenuItemData(
                  icon: Icons.directions_car_outlined,
                  label: 'Vehicles',
                  subtitle: 'DL 3C AB 1234',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehiclesScreen())),
                ),
                _MenuItemData(
                  icon: Icons.description_outlined,
                  label: 'Documents',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
                ),
                _MenuItemData(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Insurance',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceScreen())),
                ),
                _MenuItemData(
                  icon: Icons.card_membership_outlined,
                  label: 'Drive Pass',
                  subtitle: 'Gold Plan · Active',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DrivePassScreen())),
                ),
                _MenuItemData(
                  icon: Icons.receipt_long_outlined,
                  label: 'Tax Info',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxInfoScreen())),
                ),
              ], context),

              const SizedBox(height: 20),
              _buildSectionTitle('ACCOUNT'),
              const SizedBox(height: 10),
              _buildMenuCard([
                _MenuItemData(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  subtitle: '₹1,250',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  ),
                ),
                _MenuItemData(
                  icon: Icons.account_balance_outlined,
                  label: 'Bank / UPI Details',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankDetailsScreen())),
                ),
                _MenuItemData(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                _MenuItemData(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),
                _MenuItemData(
                  icon: Icons.lightbulb_outline,
                  label: 'Tips & Info',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsInfoScreen())),
                ),
                _MenuItemData(
                  icon: Icons.bug_report_outlined,
                  label: 'Bug Reporter',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BugReporterScreen())),
                ),
              ], context),

              const SizedBox(height: 20),
              _buildMenuCard([
                _MenuItemData(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  labelColor: AppTheme.criticalRed,
                  onTap: () => _showSignOutDialog(context),
                ),
              ], context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMenuCard(
      List<_MenuItemData> items, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.labelColor ?? AppTheme.primaryBlue,
                    size: 22,
                  ),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: item.labelColor ?? const Color(0xFF0A1F44),
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 74,
                  endIndent: 18,
                  color: Color(0xFFF0F4FF),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE3EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign Out?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0040A0),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "You'll be signed out of your AMBULAO driver account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          foregroundColor: AppTheme.primaryBlue,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sign Out button
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          // Fade-out transition to LoginScreen, clearing all routes
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, _, _) => const _LoginScreenProxy(),
                              transitionsBuilder: (_, anim, _, child) {
                                return FadeTransition(opacity: anim, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 600),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.criticalRed, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          foregroundColor: AppTheme.criticalRed,
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.label,
    this.subtitle,
    this.labelColor,
    required this.onTap,
  });
}

/// Proxy so menu_screen can reference LoginScreen without circular imports
class _LoginScreenProxy extends LoginScreen {
  const _LoginScreenProxy();
}
