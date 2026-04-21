import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/widgets/map_background_mock.dart';
import 'package:ambulao_driver/screens/navigate_to_hospital_screen.dart';

class StartTripScreen extends StatelessWidget {
  final String tripId;
  final String patientName;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double estimatedFare;

  const StartTripScreen({
    super.key,
    required this.tripId,
    required this.patientName,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.estimatedFare,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MapBackgroundMock(
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, spreadRadius: 2)],
                ),
                padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(context).padding.bottom + 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Verified icon
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FFF0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user, color: Color(0xFF34C759), size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Patient Verified ✓',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PIN confirmed. You can now start the trip to Yashoda Hospital.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    // Patient name chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                            child: Center(child: Text(patientName.isNotEmpty ? patientName.substring(0, 2).toUpperCase() : 'RK', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))),
                          ),
                          const SizedBox(width: 8),
                          Text(patientName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => NavigateToHospitalScreen(
                              tripId: tripId,
                              dropAddress: dropAddress,
                              dropLat: dropLat,
                              dropLng: dropLng,
                              patientName: patientName,
                              estimatedFare: estimatedFare,
                            )),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text('Start Trip 🚑', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
