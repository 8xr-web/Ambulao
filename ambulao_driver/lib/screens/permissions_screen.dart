import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/main_layout.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationGranted = false;
  bool _overlayGranted = false;
  bool _notificationsGranted = false;

  bool _locationRequested = false;
  bool _overlayRequested = false;
  bool _notificationsRequested = false;

  bool _locationSkipped = false;
  bool _overlaySkipped = false;
  bool _notificationsSkipped = false;

  bool get _canContinue =>
      _locationGranted && _overlayGranted && _notificationsGranted;

  Future<void> _requestLocation() async {
    setState(() => _locationRequested = true);
    final status = await Permission.locationWhenInUse.request();
    setState(() {
      _locationGranted = status.isGranted;
      _locationSkipped = false;
    });
  }

  Future<void> _requestOverlay() async {
    setState(() => _overlayRequested = true);
    if (Platform.isAndroid) {
      final status = await Permission.systemAlertWindow.request();
      setState(() {
        _overlayGranted = status.isGranted;
        _overlaySkipped = false;
      });
    } else {
      setState(() {
        _overlayGranted = true;
        _overlaySkipped = false;
      });
    }
  }

  Future<void> _requestNotifications() async {
    setState(() => _notificationsRequested = true);
    final status = await Permission.notification.request();
    setState(() {
      _notificationsGranted = status.isGranted;
      _notificationsSkipped = false;
    });
  }

  void _skipLocation() => setState(() => _locationSkipped = true);
  void _skipOverlay() => setState(() => _overlaySkipped = true);
  void _skipNotifications() => setState(() => _notificationsSkipped = true);

  void _continue() {
    if (_canContinue) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainLayout(initialIndex: 0)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text('ONBOARDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 16),
              const Text('AMBULAO needs a few permissions', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0A1F44), height: 1.2)),
              const SizedBox(height: 8),
              const Text('To work properly and keep you connected to dispatch.', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.4)),
              const SizedBox(height: 32),

              Expanded(
                child: ListView(
                  children: [
                    _buildPermissionCard(
                      icon: Icons.location_on,
                      title: 'Location Services',
                      description: 'To find nearby trips and navigate to patients',
                      granted: _locationGranted,
                      requested: _locationRequested,
                      skipped: _locationSkipped,
                      onRequest: _requestLocation,
                      onSkip: _skipLocation,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.layers,
                      title: 'Screen Overlay',
                      description: 'To show trip alerts while using other apps',
                      granted: _overlayGranted,
                      requested: _overlayRequested,
                      skipped: _overlaySkipped,
                      onRequest: _requestOverlay,
                      onSkip: _skipOverlay,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.notifications_active,
                      title: 'Notifications',
                      description: 'For instant trip request alerts',
                      granted: _notificationsGranted,
                      requested: _notificationsRequested,
                      skipped: _notificationsSkipped,
                      onRequest: _requestNotifications,
                      onSkip: _skipNotifications,
                    ),
                  ],
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    disabledBackgroundColor: const Color(0xFFDDE3EE),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFFA1A1A1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text('Continue →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
    required bool requested,
    required bool skipped,
    required VoidCallback onRequest,
    required VoidCallback onSkip,
  }) {
    Color borderColor = Colors.transparent;
    Color bgColor = Colors.white;
    
    if (granted) {
      borderColor = AppTheme.successGreen;
      bgColor = const Color(0xFFF0FFF5);
    } else if (skipped) {
      borderColor = Colors.amber;
      bgColor = const Color(0xFFFFF9E6);
    } else if (requested) {
      borderColor = AppTheme.primaryBlue;
      bgColor = const Color(0xFFF0F4FF);
    } else {
      borderColor = const Color(0xFFDDE3EE);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: granted ? AppTheme.successGreen.withValues(alpha: 0.1) : (skipped ? Colors.amber.withValues(alpha: 0.1) : const Color(0xFFF0F4FF)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: granted ? AppTheme.successGreen : (skipped ? Colors.amber.shade700 : AppTheme.primaryBlue),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (granted)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20),
                    SizedBox(width: 6),
                    Text('Granted', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                )
              else if (skipped)
                Row(
                  children: [
                    const Text('Skipped (Required)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w700, fontSize: 13)),
                    const Spacer(),
                    _buildAllowButton(onRequest),
                  ],
                )
              else
                Row(
                  children: [
                    TextButton(
                      // Make strictly sure this calls onSkip
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Skip for now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    // Make strictly sure this calls onRequest
                    _buildAllowButton(onRequest),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllowButton(VoidCallback onRequest) {
    return ElevatedButton(
      onPressed: onRequest,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: const Text('Allow', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
