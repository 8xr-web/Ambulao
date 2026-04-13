import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _newTripAlerts = true;
  bool _earningUpdates = true;
  bool _appUpdates = false;
  bool _promotionalOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0A1F44),
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
            const Text(
              'Trip Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A1F44),
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'New Trip Alerts',
              subtitle: 'Get notified when a new trip request is available nearby.',
              value: _newTripAlerts,
              onChanged: (val) => setState(() => _newTripAlerts = val),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Account & System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A1F44),
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Earning Updates',
              subtitle: 'Daily summaries and payout notifications.',
              value: _earningUpdates,
              onChanged: (val) => setState(() => _earningUpdates = val),
            ),
            _buildSwitchTile(
              title: 'App Updates',
              subtitle: 'New features, bug fixes, and general app announcements.',
              value: _appUpdates,
              onChanged: (val) => setState(() => _appUpdates = val),
            ),
            _buildSwitchTile(
              title: 'Promotional Offers',
              subtitle: 'Incentives, bonuses, and special driver programs.',
              value: _promotionalOffers,
              onChanged: (val) => setState(() => _promotionalOffers = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A1F44),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primaryBlue,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFDDE3EE),
          ),
        ],
      ),
    );
  }
}
