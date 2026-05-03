import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shimmer/shimmer.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../models/booking_args.dart';
import '../viewmodels/booking_provider.dart';
import '../viewmodels/user_provider.dart';
import 'main_layout.dart';
import 'ambulance_selection_screen.dart';
import 'location_selection_screen.dart';
import 'notifications_screen.dart';
import 'nurse_booking_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_hello_world/localisation/app_localizations.dart';
import '../widgets/home_screen_mini_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables for map moved to HomeScreenMiniMap

  // Navigate directly to Book Ambulance (skip location selection)
  void _goDirectToBook(BuildContext context, String destination, String ambulanceType) {
    final user = context.read<UserProvider>();
    MainLayout.homeNavKey.currentState?.push(
      SmoothPageRoute(
        page: AmbulanceSelectionScreen(
          args: BookingArgs(
            ambulanceType: ambulanceType,
            pickup: user.address,
            destination: destination,
            lat: user.latitude,
            lng: user.longitude,
          ),
        ),
      ),
    );
  }

  // Navigate to Location Selection, carrying service type
  void _goToLocationSelect(BuildContext context, String ambulanceType) {
    MainLayout.homeNavKey.currentState?.push(
      SmoothPageRoute(
        page: LocationSelectionScreen(ambulanceType: ambulanceType),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Top Bar
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<UserProvider>(
                      builder: (context, user, _) => Row(
                        children: [
                          InkWell(
                            onTap: () {
                              final mainLayout = MainLayout.of(context);
                              if (mainLayout != null) {
                                mainLayout.switchToProfile();
                              } else {
                                Navigator.of(context, rootNavigator: true).push(
                                  SmoothPageRoute(page: const ProfileScreen(heroTag: 'profile_photo')),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: SizedBox(
                              width: 48, height: 48,
                              child: Center(
                                child: Hero(
                                  tag: 'profile_photo',
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                                    child: user.photoPath != null && user.photoPath!.isNotEmpty
                                      ? ClipOval(child: kIsWeb
                                        ? Image.network(user.photoPath!, width: 44, height: 44, fit: BoxFit.cover)
                                        : Image.file(File(user.photoPath!), width: 44, height: 44, fit: BoxFit.cover))
                                      : Center(child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Adjusted width from 12 to 8 because of 48px box
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Good morning", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 13)),
                              Text("${user.name.isNotEmpty ? user.name.split(' ').first : 'there'} 👋", style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true).push(
                        SmoothPageRoute(page: const NotificationsScreen()),
                      ),
                      child: Container(
                       width: 44, height: 44,
                       decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                       child: Stack(
                         alignment: Alignment.center,
                         children: [
                           const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                           Positioned(
                             top: 12, right: 12,
                             child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle)),
                           ),
                         ],
                       ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Active Booking Banner (Fix 5) ──
              Consumer<BookingProvider>(
                builder: (context, bookingProv, _) {
                  final booking = bookingProv.activeAmbulanceBooking;
                  if (booking == null) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your ambulance is on the way!',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFF1A6FE8),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6FE8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A6FE8).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_shipping, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${booking['ambulanceType']} arriving in ${booking['etaMinutes']} min',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Text(
                            'Tap to return →',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ── 40% Map Area ──
              const HomeScreenMiniMap(),
              const SizedBox(height: 16),

              // Location Input Card
              Container(
                height: 110,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            MainLayout.homeNavKey.currentState?.push(
                              SmoothPageRoute(
                                page: const LocationSelectionScreen(
                                  ambulanceType: 'BLS',
                                  initialTab: LocTab.pickup,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle))),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Your location", style: TextStyle(color: Color(0xFF999999), fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Consumer<UserProvider>(
                                      builder: (context, user, _) {
                                        if (user.address == 'Fetching location...') {
                                          return Shimmer.fromColors(
                                            baseColor: const Color(0xFFE8F2FF),
                                            highlightColor: Colors.white,
                                            child: Container(
                                              width: 140, height: 16,
                                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                            ),
                                          );
                                        }
                                        return Text(user.address, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Consumer<UserProvider>(
                                builder: (ctx, user, _) => GestureDetector(
                                  onTap: () => ctx.read<UserProvider>().fetchCurrentLocation(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.refresh_rounded, color: AppColors.primaryBlue, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _goToLocationSelect(context, 'BLS'),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle))),
                              SizedBox(width: 16),
                              Expanded(child: Text("Where to? / Hospital name", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(100)),
                        child: const Text("For Self", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Fix 1: Apollo Hospital shortcut → direct to AmbulanceSelectionScreen ──
              GestureDetector(
                onTap: () => _goDirectToBook(context, 'Apollo Hospital, Jubilee Hills', 'BLS'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.access_time, color: Color(0xFF9CA3AF), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Apollo Hospital, Jubilee Hills", style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text("Yesterday", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Fix 1: KIMS Hospital shortcut → direct to AmbulanceSelectionScreen ──
              GestureDetector(
                onTap: () => _goDirectToBook(context, 'KIMS Hospital, Secunderabad', 'BLS'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.access_time, color: Color(0xFF9CA3AF), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("KIMS Hospital, Secunderabad", style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text("2 days ago", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 24,
                child: Text(AppLocalizations.of(context)!.ourServices, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),

              // ── Fix 2: Service tiles carry ambulanceType ──
              Column(
                children: [
                  _buildVerticalServiceCard(
                    context: context,
                    icon: Icons.medical_services_outlined,
                    title: AppLocalizations.of(context)!.blsAmbulance,
                    description: AppLocalizations.of(context)!.blsDescription,
                    onTap: () => _goToLocationSelect(context, 'BLS'),
                  ),
                  _buildVerticalServiceCard(
                    context: context,
                    icon: Icons.favorite_border,
                    title: AppLocalizations.of(context)!.alsAmbulance,
                    description: AppLocalizations.of(context)!.alsDescription,
                    onTap: () => _goToLocationSelect(context, 'ALS'),
                  ),
                  _buildVerticalServiceCard(
                    context: context,
                    icon: Icons.pedal_bike,
                    title: AppLocalizations.of(context)!.ambuBike,
                    description: AppLocalizations.of(context)!.ambuBikeDescription,
                    onTap: () => _goToLocationSelect(context, 'Bike'),
                  ),
                  // Non-localized strings kept for now, or use hardcoded string replacements
                  _buildVerticalServiceCard(
                    context: context,
                    icon: Icons.business_outlined,
                    title: 'Hospital Transfer',
                    description: 'Scheduled non-emergency hospital transfers',
                    onTap: () => MainLayout.homeNavKey.currentState?.push(
                      SmoothPageRoute(page: const LocationSelectionScreen(ambulanceType: 'BLS', isHospitalTransfer: true, initialTab: LocTab.pickup, serviceLabel: 'Hospital Transfer'))
                    ),
                  ),
                  _buildVerticalServiceCard(
                    context: context,
                    icon: Icons.favorite_border,
                    title: AppLocalizations.of(context)!.lastRide,
                    description: AppLocalizations.of(context)!.lastRideDescription,
                    onTap: () => MainLayout.homeNavKey.currentState?.push(
                      SmoothPageRoute(page: const LocationSelectionScreen(ambulanceType: 'LastRide', serviceLabel: 'LastRide — Mortuary Service'))
                    ),
                  ),
                  _buildVerticalServiceCard(
                    context: context,
                    icon: Icons.personal_injury_outlined,
                    title: 'Nurse at Home',
                    description: 'Professional nursing care at your doorstep',
                    onTap: () => MainLayout.homeNavKey.currentState?.push(
                      SmoothPageRoute(page: const NurseBookingScreen())
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color.fromRGBO(26, 111, 232, 0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12), maxLines: 2, overflow: TextOverflow.visible),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
}
