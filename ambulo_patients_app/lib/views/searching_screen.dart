import 'dart:async';
import 'package:flutter/material.dart';
import '../core/transitions.dart';
import '../core/theme.dart';
import '../models/booking_args.dart';
import 'main_layout.dart';
import 'ambulance_assigned_screen.dart';

class SearchingScreen extends StatefulWidget {
  final BookingArgs args;
  const SearchingScreen({super.key, required this.args});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sonarController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Sonar Animation
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Auto-transition to Assigned after 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        MainLayout.homeNavKey.currentState?.popUntil((route) => route.isFirst);
        Navigator.of(context, rootNavigator: true).push(
          SmoothPageRoute(page: AmbulanceAssignedScreen(args: widget.args)),
        );
      }
    });
  }

  @override
  void dispose() {
    _sonarController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://static-maps.yandex.ru/1.x/?lang=en_US&ll=78.3813,17.4398&z=13&l=map&size=600,450'),
                  fit: BoxFit.cover,
                ),
              ),
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
                         _timer?.cancel();
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
