import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/transitions.dart';
import '../core/theme.dart';
import 'in_app_chat_screen.dart';
import 'ambulance_moving_screen.dart';
import 'trip_completed_patient_screen.dart';

/// Screen shown after driver accepts and is on the way to pick up the patient.
/// Receives live Firestore data fields directly (unlike [AmbulanceAssignedScreen]
/// which relies on [BookingArgs]), enabling real driver information.
class AmbulanceArrivingScreen extends StatelessWidget {
  final String tripId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String driverPhoto;
  final String ambulanceType;
  final String pickupAddress;
  final String dropAddress;
  final double estimatedFare;

  const AmbulanceArrivingScreen({
    Key? key,
    required this.tripId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.driverPhoto,
    required this.ambulanceType,
    required this.pickupAddress,
    required this.dropAddress,
    required this.estimatedFare,
  }) : super(key: key);

  Future<void> _callDriver(BuildContext context) async {
    if (driverPhone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: driverPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open dialer')),
        );
      }
    }
  }

  String get _ambulanceLabel {
    switch (ambulanceType.toUpperCase()) {
      case 'ALS': return 'ALS';
      case 'BIKE':
      case 'AMBUBIKE': return 'Ambu Bike';
      case 'LASTRIDE': return 'Last Ride';
      default: return 'BLS';
    }
  }

  Color get _badgeColor {
    switch (ambulanceType.toUpperCase()) {
      case 'ALS': return const Color(0xFF003366);
      case 'BIKE':
      case 'AMBUBIKE': return const Color(0xFF10B981);
      case 'LASTRIDE': return const Color(0xFF6B7280);
      default: return const Color(0xFF1A6FE8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Map background placeholder
          Positioned(
            top: 0, left: 0, right: 0,
            bottom: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=78.3813,17.4398&z=13&l=map&size=600,600',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text('🚑', style: TextStyle(fontSize: 48)),
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.48,
            minChildSize: 0.30,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.30, 0.48, 0.85],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 48, height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),

                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34C759),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Driver Accepted — Arriving',
                                style: TextStyle(
                                  color: Color(0xFF065F46),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Driver card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  driverName.isNotEmpty ? driverName[0].toUpperCase() : 'D',
                                  style: const TextStyle(
                                    color: Color(0xFF1A6FE8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driverName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _badgeColor,
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Text(_ambulanceLabel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(vehicleNumber,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.85),
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Arriving badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Arriving', style: TextStyle(color: Colors.white, fontSize: 11)),
                                const SizedBox(height: 4),
                                const Text('~4 min',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Route summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, color: Color(0xFF34C759), size: 12),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(pickupAddress.isEmpty ? 'Your location' : pickupAddress,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              width: 2, height: 20,
                              color: const Color(0xFFE5E7EB),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF1A6FE8), size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(dropAddress.isEmpty ? 'Destination' : dropAddress,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fare row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Fare',
                                style: TextStyle(color: Color(0xFF6B7A99), fontWeight: FontWeight.w600)),
                            Text('₹${estimatedFare.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF1A6FE8),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.call,
                              label: 'Call',
                              onTap: () => _callDriver(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.chat_bubble_outline,
                              label: 'Chat',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(page: const InAppChatScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
