import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambulao_driver/screens/active_navigation_screen.dart';
import 'package:ambulao_driver/widgets/map_background_mock.dart';
import 'package:ambulao_driver/core/theme.dart';

class IncomingRequestScreen extends StatefulWidget {
  final String tripId;
  final String patientName;
  final String ambulanceType;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double estimatedFare;
  final String? patientPhone;

  const IncomingRequestScreen({
    super.key,
    required this.tripId,
    required this.patientName,
    required this.ambulanceType,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.estimatedFare,
    this.patientPhone,
  });

  @override
  State<IncomingRequestScreen> createState() => _IncomingRequestScreenState();
}

class _IncomingRequestScreenState extends State<IncomingRequestScreen>
    with SingleTickerProviderStateMixin {
  int _countdown = 15;
  Timer? _timer;
  double _progress = 1.0;
  bool _isAccepting = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _countdown--;
          _progress = _countdown / 15.0;
        });
      }
    });

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _acceptTrip() async {
    _timer?.cancel();
    setState(() => _isAccepting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getString('driver_uid') ?? '';
      final driverName = prefs.getString('profile_name') ?? 'Driver';
      final driverPhone = prefs.getString('driver_phone') ?? '';
      final vehicleNumber = prefs.getString('profile_vehicle') ?? '';

      // Update trip in Firestore — patient app is listening for this
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'driver_id': driverId,
        'driver_name': driverName,
        'driver_phone': driverPhone,
        'vehicle_number': vehicleNumber,
        'status': 'accepted',
        'accepted_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'estimated_time': '8',
      });

      // Update driver document
      if (driverId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(driverId)
            .set({
          'current_trip_id': widget.tripId,
          'status': 'on_trip',
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveNavigationScreen(
            tripId: widget.tripId,
            patientName: widget.patientName,
            pickupAddress: widget.pickupAddress,
            pickupLat: widget.pickupLat,
            pickupLng: widget.pickupLng,
            dropAddress: widget.dropAddress,
            dropLat: widget.dropLat,
            dropLng: widget.dropLng,
            estimatedFare: widget.estimatedFare,
            patientPhone: widget.patientPhone ?? '',
          ),
        ),
      );
    } catch (e) {
      setState(() => _isAccepting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _declineTrip() {
    _timer?.cancel();
    Navigator.pop(context);
  }

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
              // Bottom sheet card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top pulsing border strip
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) => Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.criticalRed.withValues(alpha: _pulseAnim.value),
                              AppTheme.primaryBlue.withValues(alpha: 1.0 - _pulseAnim.value),
                              AppTheme.criticalRed.withValues(alpha: _pulseAnim.value),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.02),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Type and Rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Pulsing EMERGENCY badge
                              AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (context, child) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.criticalRed.withValues(alpha: 0.1 + (_pulseAnim.value * 0.1)),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: AppTheme.criticalRed.withValues(alpha: 0.3 + (_pulseAnim.value * 0.5)),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_hospital, color: AppTheme.criticalRed, size: 16),
                                      const SizedBox(width: 6),
                                      const Text('EMERGENCY',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.criticalRed, letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              ),
                              // Ambulance type badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  widget.ambulanceType,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Patient and Fare Info
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE8F2FF),
                                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.patientName.isNotEmpty ? widget.patientName[0].toUpperCase() : 'P',
                                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Distance / Addresses
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.patientName,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.pickupAddress,
                                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Est Fare
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F2FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('EST. FARE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, letterSpacing: 0.5)),
                                    Text(
                                      '₹${widget.estimatedFare.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0040A0)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Route Preview
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBFF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFDDE3EE)),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle)),
                                    Container(width: 2, height: 20, color: const Color(0xFFDDE3EE), margin: const EdgeInsets.symmetric(vertical: 4)),
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.rectangle)),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.pickupAddress,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.dropAddress,
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Action Buttons
                          Row(
                            children: [
                              // Decline
                              TextButton(
                                onPressed: _isAccepting ? null : _declineTrip,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                child: const Text('Decline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                              ),
                              const SizedBox(width: 16),
                              // Accept
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                            blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isAccepting ? null : _acceptTrip,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          elevation: 0,
                                        ),
                                        child: _isAccepting
                                            ? const SizedBox(
                                                width: 24, height: 24,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.local_hospital, size: 22),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Accept (${_countdown}s)',
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    // Circular progress ring
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: CircularProgressIndicator(
                                          value: _progress,
                                          strokeWidth: 4,
                                          color: Colors.white.withValues(alpha: 0.2),
                                        ),
                                      ),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
