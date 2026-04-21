import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import 'main_layout.dart';
import 'nurse_assigned_screen.dart';
import '../core/transitions.dart';

class NurseSearchingScreen extends StatefulWidget {
  final String serviceLabel;
  final int durationHours;
  final String nurseName;
  final int totalPrice;

  const NurseSearchingScreen({
    super.key,
    required this.serviceLabel,
    required this.durationHours,
    required this.nurseName,
    required this.totalPrice,
  });

  @override
  State<NurseSearchingScreen> createState() => _NurseSearchingScreenState();
}

class _NurseSearchingScreenState extends State<NurseSearchingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sonarController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      MainLayout.homeNavKey.currentState?.pushReplacement(
        SmoothPageRoute(
          page: NurseAssignedScreen(
            serviceLabel: widget.serviceLabel,
            durationHours: widget.durationHours,
            nurseName: widget.nurseName,
            totalPrice: widget.totalPrice,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sonarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.45,
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(17.3850, 78.4867),
                zoom: 13,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => MainLayout.homeNavKey.currentState?.pop(),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.5 - 100,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _sonarController,
                    builder: (context, child) {
                      return Container(
                        width: 50 + (100 * _sonarController.value),
                        height: 50 + (100 * _sonarController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(
                                alpha: 1.0 - _sonarController.value),
                            width: 2,
                          ),
                          color: AppColors.primaryBlue.withValues(
                            alpha: (0.25 - 0.25 * _sonarController.value)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        color: AppColors.primaryBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.personal_injury_outlined,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.findingAvailableNurse,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(100)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.medical_services_outlined,
                            color: AppColors.primaryBlue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          widget.serviceLabel,
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '${widget.durationHours} hrs · ₹${widget.totalPrice}',
                    style: const TextStyle(
                      color: Color(0xFF6E6E73),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: OutlinedButton(
                      onPressed: () {
                        _timer?.cancel();
                        MainLayout.homeNavKey.currentState?.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(
                            color: Color(0xFFE5E7EB), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close,
                              color: Color(0xFFFF3B30), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Cancel Request",
                            style: TextStyle(
                                color: Color(0xFFFF3B30),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

