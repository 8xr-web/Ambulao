import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/firestore_service.dart';

import '../core/theme.dart';
import '../models/booking_args.dart';
import 'main_layout.dart';
import 'ambulance_assigned_screen.dart';
import 'live_tracking_screen.dart';
import 'trip_completed_screen.dart';

class SearchingScreen extends StatefulWidget {
  final BookingArgs args;
  const SearchingScreen({super.key, required this.args});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sonarController;
  StreamSubscription<DocumentSnapshot>? _tripSubscription;
  String? _currentTripId;

  @override
  void initState() {
    super.initState();
    // Sonar Animation
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _initiateRealTrip();
  }

  Future<void> _initiateRealTrip() async {
    try {
      _currentTripId = await FirestoreService.createTripRequest(
        ambulanceType: widget.args.ambulanceType,
        // Mocked GPS coordinates for the prototype
        pickup: {'address': widget.args.pickup, 'lat': 17.4399, 'lng': 78.3813},
        destination: {'address': widget.args.destination, 'lat': 17.4500, 'lng': 78.3900},
        paymentMethod: 'Cash',
      );

      _tripSubscription = FirestoreService.getTripStream(_currentTripId!).listen((snapshot) async {
        if (!snapshot.exists || !mounted) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'searching';

        // ── ACCEPTED ──────────────────────────────────────────
        if (status == 'accepted') {
          _tripSubscription?.cancel();
          final driverId = data['driver_id'] as String? ?? '';
          Map<String, dynamic> driverData = {};

          if (driverId.isNotEmpty) {
            final driverDoc = await FirebaseFirestore.instance
                .collection('drivers')
                .doc(driverId)
                .get();
            driverData = driverDoc.data() ?? {};
          }

          if (!mounted) return;
          MainLayout.homeNavKey.currentState?.popUntil((route) => route.isFirst);
          Navigator.of(context, rootNavigator: true).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, _) =>
                  AmbulanceAssignedScreen(
                tripId: _currentTripId!,
                driverId: driverId,
                driverName: data['driver_name'] as String? ??
                    driverData['name'] as String? ?? 'Driver',
                driverPhone: data['driver_phone'] as String? ??
                    driverData['phone'] as String? ?? '',
                vehicleNumber: data['vehicle_number'] as String? ??
                    driverData['vehicle_number'] as String? ?? '',
                ambulanceType: widget.args.ambulanceType,
                pickupAddress: widget.args.pickup,
                dropAddress: widget.args.destination,
                estimatedFare:
                    ((data['estimated_fare'] ?? 350.0) as num).toDouble(),
                pickupLat: (data['pickup']?['lat'] as num?)?.toDouble() ?? 17.4399,
                pickupLng: (data['pickup']?['lng'] as num?)?.toDouble() ?? 78.3813,
              ),
              transitionsBuilder: (context, animation, _, child) =>
                  SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            ),
          );
        }

        // ── ON TRIP ───────────────────────────────────────────
        if (status == 'on_trip') {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LiveTrackingScreen(
                tripId: _currentTripId!,
                driverName: data['driver_name'] as String? ?? 'Driver',
                driverPhone: data['driver_phone'] as String? ?? '',
                vehicleNumber: data['vehicle_number'] as String? ?? '',
                ambulanceType:
                    data['ambulance_type'] as String? ?? widget.args.ambulanceType,
                dropAddress:
                    (data['destination'] as Map<String, dynamic>?)?['address']
                            as String? ??
                        widget.args.destination,
                estimatedFare:
                    ((data['estimated_fare'] ?? 350.0) as num).toDouble(),
              ),
            ),
          );
        }

        // ── COMPLETED ─────────────────────────────────────────
        if (status == 'completed') {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TripCompletedScreen(
                tripId: _currentTripId!,
                driverName: data['driver_name'] as String? ?? 'Driver',
                ambulanceType:
                    data['ambulance_type'] as String? ?? widget.args.ambulanceType,
                pickupAddress:
                    (data['pickup'] as Map<String, dynamic>?)?['address']
                            as String? ??
                        widget.args.pickup,
                dropAddress:
                    (data['destination'] as Map<String, dynamic>?)?['address']
                            as String? ??
                        widget.args.destination,
                totalFare: ((data['final_fare'] ??
                        data['estimated_fare'] ?? 350.0) as num)
                    .toDouble(),
                paymentMethod:
                    data['payment_method'] as String? ?? 'cash',
              ),
            ),
          );
        }

        // ── CANCELLED ─────────────────────────────────────────
        if (status == 'cancelled') {
          _tripSubscription?.cancel();
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Trip was cancelled'),
              backgroundColor: const Color(0xFFFF3B30),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint("Error creating trip request: $e");
    }
  }

  @override
  void dispose() {
    _sonarController.dispose();
    _tripSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map Background
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(17.3850, 78.4867),
                zoom: 13,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          
          // 2. Animated Sonar Rings
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.5 - 100,
            child: SizedBox(
               width: 200, height: 200,
               child: Stack(
                 alignment: Alignment.center,
                 children: [
                   // Inner Ring
                   AnimatedBuilder(
                     animation: _sonarController,
                     builder: (context, child) {
                       return Container(
                         width: 50 + (100 * _sonarController.value),
                         height: 50 + (100 * _sonarController.value),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 1.0 - _sonarController.value), width: 2),
                           color: AppColors.primaryBlue.withValues(alpha: (0.3 - 0.3 * _sonarController.value).clamp(0.0, 1.0)),
                         ),
                       );
                     },
                   ),
                   // Outer Ring
                   AnimatedBuilder(
                     animation: _sonarController,
                     builder: (context, child) {
                       double delayedValue = (_sonarController.value - 0.5) * 2;
                       if (delayedValue < 0) delayedValue = 0;
                       return Container(
                         width: 100 + (100 * delayedValue),
                         height: 100 + (100 * delayedValue),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 1.0 - delayedValue), width: 1),
                           color: Colors.transparent,
                         ),
                       );
                     },
                   ),
                   // Center Dot
                   Container(
                     width: 24, height: 24,
                     decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                   )
                 ],
               )
            ),
          ),

          // 3. Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                     // Handle
                     Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
                     const SizedBox(height: 32),
                   
                   // Blue Icon Circle
                   Container(
                     width: 80, height: 80,
                     decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                     child: Icon(
                       widget.args.ambulanceType == 'ALS'
                           ? Icons.favorite_border
                           : widget.args.ambulanceType == 'Bike'
                               ? Icons.pedal_bike
                               : widget.args.ambulanceType == 'LastRide'
                                   ? Icons.airport_shuttle_outlined
                                   : Icons.medical_services_outlined,
                       color: Colors.white,
                       size: 40,
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // Titles
                   const Text("Finding nearest ambulance...", style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   
                   // Chip
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(100)),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         const Icon(Icons.directions_car, color: AppColors.primaryBlue, size: 16),
                         const SizedBox(width: 8),
                         Text(
                           widget.args.ambulanceType == 'ALS'
                               ? 'ALS Ambulance'
                               : widget.args.ambulanceType == 'Bike'
                                   ? 'Ambu Bike'
                                   : widget.args.ambulanceType == 'LastRide'
                                       ? 'Last Ride'
                                       : 'BLS Ambulance',
                           style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   // Loading Dots
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       _buildBlinkingDot(0),
                       const SizedBox(width: 8),
                       _buildBlinkingDot(1),
                       const SizedBox(width: 8),
                       _buildBlinkingDot(2),
                     ],
                   ),
                   const SizedBox(height: 16),
                   
                   // ETA
                   const Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text("Estimated arrival: ", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 13)),
                       Text("4 min", style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const Spacer(),
                   
                   // Cancel Button
                   Padding(
                     padding: const EdgeInsets.only(bottom: 96), // Clearance for the global pill
                     child: OutlinedButton(
                       onPressed: () {
                         if (_currentTripId != null) {
                           FirestoreService.cancelTrip(_currentTripId!);
                         }
                         _tripSubscription?.cancel();
                         MainLayout.homeNavKey.currentState?.popUntil((route) => route.isFirst);
                       },
                       style: OutlinedButton.styleFrom(
                         minimumSize: const Size(double.infinity, 56),
                         side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       ),
                       child: const Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.close, color: Color(0xFFFF3B30), size: 20),
                           SizedBox(width: 8),
                           Text("Cancel Request", style: TextStyle(color: Color(0xFFFF3B30), fontSize: 16, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildBlinkingDot(int index) {
    return AnimatedBuilder(
      animation: _sonarController,
      builder: (context, child) {
        // Simple distinct opacity per dot based on the timer offset
        double opacity = ((_sonarController.value * 3 + index) % 3) / 3.0;
        return Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: opacity), shape: BoxShape.circle),
        );
      },
    );
  }
}
