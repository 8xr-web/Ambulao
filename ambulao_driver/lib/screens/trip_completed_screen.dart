import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/providers/trip_provider.dart';
import 'package:ambulao_driver/screens/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripCompletedScreen extends ConsumerWidget {
  final double fare;
  final String dropAddress;

  const TripCompletedScreen({
    super.key,
    this.fare = 0.0,
    this.dropAddress = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header icon with blue glow instead of amber star/confetti
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryBlue,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Trip Completed! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Here's your summary for this trip",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    label: 'Fare Earned',
                    value: '₹${fare.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: AppTheme.successGreen,
                  ),
                  _StatCard(
                    label: 'Distance',
                    value: '12.4 km',
                    icon: Icons.route,
                    color: AppTheme.primaryBlue,
                  ),
                  _StatCard(
                    label: 'Trip Duration',
                    value: '38m',
                    icon: Icons.access_time,
                    color: const Color(0xFFFF9500),
                  ),
                  _StatCard(
                    label: 'Rating',
                    value: '5.0',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),

              const Spacer(),

              // Action Buttons
              // Go Online
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('driver_is_online', true);
                    final uid = prefs.getString('driver_uid') ?? '';
                    if (uid.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('drivers').doc(uid).update({'isOnline': true});
                    }

                    ref.read(tripProvider.notifier).resetTrip();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => MainLayout(),
                          settings: const RouteSettings(arguments: {'isOnline': true}),
                        ),
                        (_) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go Online',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Take a Break
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('driver_is_online', false);
                    final uid = prefs.getString('driver_uid') ?? '';
                    if (uid.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('drivers').doc(uid).update({'isOnline': false});
                    }

                    ref.read(tripProvider.notifier).resetTrip();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => MainLayout(),
                          settings: const RouteSettings(arguments: {'isOnline': false}),
                        ),
                        (_) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Take a Break',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
