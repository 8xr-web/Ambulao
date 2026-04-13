import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrivingPreferencesScreen extends StatefulWidget {
  const DrivingPreferencesScreen({super.key});

  @override
  State<DrivingPreferencesScreen> createState() => _DrivingPreferencesScreenState();
}

class _DrivingPreferencesScreenState extends State<DrivingPreferencesScreen> {
  bool _acceptEmergency = true;
  bool _autoAccept = false;
  bool _nightMode = false;
  bool _highTrafficAlerts = true;
  
  String _navApp = 'google';
  String _routeType = 'fastest';
  bool _avoidTolls = false;
  bool _avoidMotorways = false;
  bool _avoidFerries = false;
  bool _soundAlerts = true;
  bool _vibration = true;
  String _availableFrom = '06:00';
  String _availableUntil = '22:00';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _acceptEmergency = prefs.getBool('pref_accept_emergency') ?? true;
      _autoAccept = prefs.getBool('pref_auto_accept') ?? false;
      _nightMode = prefs.getBool('pref_night_mode') ?? false;
      _highTrafficAlerts = prefs.getBool('pref_high_traffic_alerts') ?? true;
      
      _navApp = prefs.getString('pref_nav_app') ?? 'google';
      _routeType = prefs.getString('pref_route_type') ?? 'fastest';
      _avoidTolls = prefs.getBool('pref_avoid_tolls') ?? false;
      _avoidMotorways = prefs.getBool('pref_avoid_motorways') ?? false;
      _avoidFerries = prefs.getBool('pref_avoid_ferries') ?? false;
      _soundAlerts = prefs.getBool('pref_sound_alerts') ?? true;
      _vibration = prefs.getBool('pref_vibration') ?? true;
      _availableFrom = prefs.getString('pref_available_from') ?? '06:00';
      _availableUntil = prefs.getString('pref_available_until') ?? '22:00';
      
      _isLoading = false;
    });
  }

  Future<void> _updateToggle(String key, bool value, ValueChanged<bool> stateSetter) async {
    stateSetter(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('pref_accept_emergency', _acceptEmergency);
    await prefs.setBool('pref_auto_accept', _autoAccept);
    await prefs.setBool('pref_night_mode', _nightMode);
    await prefs.setBool('pref_high_traffic_alerts', _highTrafficAlerts);

    await prefs.setString('pref_nav_app', _navApp);
    await prefs.setString('pref_route_type', _routeType);
    await prefs.setBool('pref_avoid_tolls', _avoidTolls);
    await prefs.setBool('pref_avoid_motorways', _avoidMotorways);
    await prefs.setBool('pref_avoid_ferries', _avoidFerries);
    await prefs.setBool('pref_sound_alerts', _soundAlerts);
    await prefs.setBool('pref_vibration', _vibration);
    await prefs.setString('pref_available_from', _availableFrom);
    await prefs.setString('pref_available_until', _availableUntil);

    final uid = prefs.getString('driver_uid') ?? '';
    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('drivers').doc(uid).update({
        'drivingPreferences': {
          'acceptEmergency': _acceptEmergency,
          'autoAccept': _autoAccept,
          'nightMode': _nightMode,
          'highTrafficAlerts': _highTrafficAlerts,
          'navApp': _navApp,
          'routeType': _routeType,
          'avoidTolls': _avoidTolls,
          'avoidMotorways': _avoidMotorways,
          'avoidFerries': _avoidFerries,
          'soundAlerts': _soundAlerts,
          'vibration': _vibration,
          'availableFrom': _availableFrom,
          'availableUntil': _availableUntil,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferences saved ✓', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Driving Preferences', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text('TRIP SETTINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
                ),
                _buildPreferenceCard([
                  _buildToggleRow(
                    Icons.emergency_outlined,
                    'Accept Emergency Trips',
                    'Prioritize high-urgency patient transfers',
                    _acceptEmergency,
                    (v) => _updateToggle('pref_accept_emergency', v, (val) => setState(() => _acceptEmergency = val)),
                  ),
                  const Divider(height: 1),
                  _buildToggleRow(
                    Icons.bolt_outlined,
                    'Auto-Accept Requests',
                    'Automatically accept new incoming trips',
                    _autoAccept,
                    (v) => _updateToggle('pref_auto_accept', v, (val) => setState(() => _autoAccept = val)),
                  ),
                ]),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text('MAP & NAVIGATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0)),
                ),
                _buildPreferenceCard([
                  _buildToggleRow(
                    Icons.dark_mode_outlined,
                    'Night Mode Map',
                    'Apply dark theme to navigation maps',
                    _nightMode,
                    (v) => _updateToggle('pref_night_mode', v, (val) => setState(() => _nightMode = val)),
                  ),
                  const Divider(height: 1),
                  _buildToggleRow(
                    Icons.traffic_outlined,
                    'High Traffic Alerts',
                    'Notify when route has significant delays',
                    _highTrafficAlerts,
                    (v) => _updateToggle('pref_high_traffic_alerts', v, (val) => setState(() => _highTrafficAlerts = val)),
                  ),
                  const Divider(height: 1),
                  _buildToggleRow(
                    Icons.toll_outlined,
                    'Avoid Tolls',
                    'Try to exclude toll roads from routes',
                    _avoidTolls,
                    (v) => _updateToggle('pref_avoid_tolls', v, (val) => setState(() => _avoidTolls = val)),
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _saveAllPreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text('Save Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleRow(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryBlue,
            activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
