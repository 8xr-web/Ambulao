import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme.dart';
import '../models/booking_args.dart';
import 'trip_completed_screen.dart';
import 'home_screen.dart';
import 'booking_history_screen.dart';
import 'panic_mode_screen.dart';
import 'profile_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Simulate arriving at destination after 10 seconds for demo purposes
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TripCompletedScreen(args: BookingArgs())),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full Screen Map
          Positioned.fill(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(37.7858,
                    -122.4064), // Used San Francisco coordinates as an example
                initialZoom: 15.0,
                interactionOptions:
                    InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_hello_world',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(37.7858, -122.4064),
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: const Icon(Icons.local_shipping,
                                      color: AppColors.primaryBlue, size: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top Navigation Elements
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                    // ETA Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "ESTIMATED ARRIVAL",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                letterSpacing: 1),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "05 : 24",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),

                    // Cancel Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.errorRed.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Map Action Buttons
          Positioned(
            right: 16,
            bottom: 320, // Above the driver card
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.near_me_outlined,
                        color: AppColors.primaryBlue),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.show_chart,
                        color: AppColors
                            .primaryBlue), // Pulse line icon equivalent
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info Card & Nav Pill Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Driver Info Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Blue Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.show_chart,
                                    color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "MEDICAL TEAM PREPARED",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.5),
                                ),
                              ),
                              const Text(
                                "DETAILS",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),

                        // Driver Info Body
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlueAccent
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.local_shipping,
                                        color: AppColors.primaryBlue, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("ICU Ambulance 741",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary)),
                                        SizedBox(height: 4),
                                        Text("DRIVER: MARK JOHNSON",
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color:
                                                    AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: AppColors.primaryBlue,
                                              size: 16),
                                          SizedBox(width: 4),
                                          Text("4.9",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColors.primaryBlue)),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text("AB-4567",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.textSecondary)),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 1.5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                        child: const Text("CANCEL",
                                            style: TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.phone_outlined,
                                            color: Colors.white, size: 18),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                        label: const Text("CALL\nDRIVER",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                height: 1.1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Bottom Navigation Pill (from Image 4, if needed here or on another screen)
                // The provided Live Tracking Screen image doesn't show the nav pill but let's assume it should exist at the bottom
                // The third provided image has a bottom pill. Wait, the third image is actually... let me check the image.
                // Image 3 contains the pill "home, history, alert, profile".
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 16, left: 16, right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home_outlined),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.history),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BookingHistoryScreen()),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.primaryBlue.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.error_outline),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PanicModeScreen()),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_outline),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
