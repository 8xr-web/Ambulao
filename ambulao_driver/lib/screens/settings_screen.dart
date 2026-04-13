import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundAlerts = true;
  bool _vibration = true;
  bool _darkMode = false;
  String _language = 'English';
  String _navApp = 'Google Maps';
  String _locationStatus = 'Always On'; // 'Always On' | 'While Using' | 'Disabled'

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Select Language',
        options: const ['English', 'Hindi', 'Telugu'],
        selected: _language,
        onSelect: (v) => setState(() => _language = v),
      ),
    );
  }

  void _showNavAppPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'Navigation App',
        options: const ['Google Maps', 'Apple Maps', 'Waze'],
        selected: _navApp,
        onSelect: (v) => setState(() => _navApp = v),
      ),
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 48, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 40),
          const SizedBox(height: 12),
          const Text('Location Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52,
              child: OutlinedButton(
                  onPressed: () { setState(() => _locationStatus = 'While Using'); Navigator.pop(context); },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Change to While Using', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)))),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 52,
              child: OutlinedButton(
                  onPressed: () { setState(() => _locationStatus = 'Disabled'); Navigator.pop(context); },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.criticalRed, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Disable Location', style: TextStyle(color: AppTheme.criticalRed, fontWeight: FontWeight.w700)))),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                  onPressed: () { setState(() => _locationStatus = 'Always On'); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Enable Always On', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]),
      ),
    );
  }

  void _showDeleteStep1() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Color(0xFFFFEEEA), shape: BoxShape.circle),
              child: const Icon(Icons.warning_rounded, color: AppTheme.criticalRed, size: 36)),
          const SizedBox(height: 16),
          const Text('Delete Your Account?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
          const SizedBox(height: 12),
          const Text('This will permanently delete your AMBULAO driver account, earnings history, and all personal data. This action cannot be undone.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); _showDeleteStep2(); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.criticalRed, elevation: 0, side: const BorderSide(color: AppTheme.criticalRed, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)))),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]),
      ),
    );
  }

  void _showDeleteStep2() {
    String? selectedReason;
    final reasons = ['Switching to another platform', 'Too many issues with the app', 'Not enough trips in my area', 'Privacy concerns', 'Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) => Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx2).padding.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text('Why are you leaving?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
            const SizedBox(height: 20),
            Wrap(spacing: 10, runSpacing: 10, children: reasons.map((r) {
              final sel = r == selectedReason;
              return GestureDetector(
                onTap: () => setSt(() => selectedReason = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: sel ? AppTheme.primaryBlue : Colors.white, borderRadius: BorderRadius.circular(50), border: Border.all(color: sel ? AppTheme.primaryBlue : const Color(0xFFDDE3EE), width: 1.5)),
                  child: Text(r, style: TextStyle(color: sel ? Colors.white : const Color(0xFF0A1F44), fontWeight: FontWeight.w600, fontSize: 13))));
            }).toList()),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52,
                child: ElevatedButton(
                    onPressed: selectedReason == null ? null : () { Navigator.pop(ctx); _showDeleteStep3(); },
                    style: ElevatedButton.styleFrom(backgroundColor: selectedReason != null ? AppTheme.primaryBlue : Colors.grey.shade300, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                    child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)))),
          ]),
        ),
      ),
    );
  }

  void _showDeleteStep3() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx2, setSt) => Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('Final Confirmation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
              const SizedBox(height: 12),
              const Text('Type DELETE to confirm permanent deletion.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                onChanged: (_) => setSt(() {}),
                decoration: InputDecoration(
                    hintText: 'Type DELETE here', filled: true, fillColor: const Color(0xFFF5F8FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: ctrl.text == 'DELETE' ? AppTheme.criticalRed : AppTheme.primaryBlue, width: 2)),
                    contentPadding: const EdgeInsets.all(16)),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 2)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 56,
                  child: ElevatedButton(
                      onPressed: ctrl.text == 'DELETE' ? () { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false); } : null,
                      style: ElevatedButton.styleFrom(backgroundColor: ctrl.text == 'DELETE' ? AppTheme.criticalRed : Colors.grey.shade300, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                      child: const Text('Permanently Delete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDark = _darkMode;
    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0A1628),
              cardColor: const Color(0xFF1C2A40),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0A1628),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF9FBFF),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF9FBFF),
                foregroundColor: Color(0xFF0A1F44),
                elevation: 0,
              ),
            ),
      child: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0A1F44)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0A1F44),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('App Preferences', isDark),
                _buildCard(isDark, [
                  _buildToggleTile(
                    icon: Icons.volume_up_outlined,
                    label: 'Sound Alerts',
                    value: _soundAlerts,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _soundAlerts = v),
                  ),
                  _divider(isDark),
                  _buildToggleTile(
                    icon: Icons.vibration_outlined,
                    label: 'Vibration',
                    value: _vibration,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _vibration = v),
                  ),
                  _divider(isDark),
                  _buildToggleTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    value: _darkMode,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                  _divider(isDark),
                  _buildTapTile(
                    icon: Icons.language_outlined,
                    label: 'Language',
                    value: _language,
                    isDark: isDark,
                    onTap: _showLanguagePicker,
                  ),
                  _divider(isDark),
                  _buildTapTile(
                    icon: Icons.map_outlined,
                    label: 'Navigation App',
                    value: _navApp,
                    isDark: isDark,
                    onTap: _showNavAppPicker,
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionLabel('Privacy & Data', isDark),
                _buildCard(isDark, [
                  _buildLocationTile(isDark),
                  _divider(isDark),
                  _buildTapTile(
                    icon: Icons.delete_forever_outlined,
                    label: 'Delete Account',
                    value: null,
                    isDark: isDark,
                    onTap: _showDeleteStep1,
                    isDestructive: true,
                  ),
                ]),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Ambulao Driver v1.2.0 (Build 42)',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white38 : AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2A40) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        indent: 56,
        endIndent: 16,
        color: isDark ? Colors.white12 : const Color(0xFFF0F4FF),
      );

  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0A1F44),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryBlue,
            activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile({
    required IconData icon,
    required String label,
    required String? value,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? AppTheme.criticalRed : AppTheme.primaryBlue, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppTheme.criticalRed : (isDark ? Colors.white : const Color(0xFF0A1F44)),
                  ),
                ),
              ),
              if (value != null) ...[
                Text(value, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppTheme.textSecondary)),
                const SizedBox(width: 6),
              ],
              Icon(Icons.chevron_right, color: isDark ? Colors.white38 : AppTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLocationTile(bool isDark) {
    Color badgeColor;
    Color badgeBg;
    switch (_locationStatus) {
      case 'Always On': badgeColor = AppTheme.successGreen; badgeBg = const Color(0xFFE0F7E9); break;
      case 'While Using': badgeColor = const Color(0xFFB45309); badgeBg = const Color(0xFFFFF3CD); break;
      default: badgeColor = AppTheme.criticalRed; badgeBg = const Color(0xFFFFEEEA);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showLocationSheet,
        borderRadius: BorderRadius.circular(20),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue, size: 22),
            const SizedBox(width: 16),
            const Expanded(child: Text('Location Services',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44)))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(50)),
              child: Text('● $_locationStatus',
                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.w700, fontSize: 11))),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
          ]),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 48, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
          const SizedBox(height: 20),
          ...options.map((opt) {
            final isSelected = opt == selected;
            return ListTile(
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
              contentPadding: EdgeInsets.zero,
              title: Text(
                opt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : const Color(0xFF0A1F44),
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                  : const Icon(Icons.radio_button_unchecked, color: Color(0xFFDDE3EE)),
            );
          }),
        ],
      ),
    );
  }
}
