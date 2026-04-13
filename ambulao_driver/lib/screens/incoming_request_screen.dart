import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ambulao_driver/screens/active_navigation_screen.dart';
import 'package:ambulao_driver/widgets/map_background_mock.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ambulao_driver/providers/trip_provider.dart';

class IncomingRequestScreen extends ConsumerStatefulWidget {
  const IncomingRequestScreen({super.key});

  @override
  ConsumerState<IncomingRequestScreen> createState() =>
      _IncomingRequestScreenState();
}

class _IncomingRequestScreenState extends ConsumerState<IncomingRequestScreen>
    with SingleTickerProviderStateMixin {
  int _countdown = 15;
  Timer? _timer;
  double _progress = 1.0;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        if (mounted) {
          ref.read(tripProvider.notifier).resetTrip();
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _countdown--;
          _progress = _countdown / 15.0;
        });
      }
    });

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _acceptTrip() {
    _timer?.cancel();
    ref.read(tripProvider.notifier).acceptTrip();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ActiveNavigationScreen()),
    );
  }

  void _declineTrip() {
    _timer?.cancel();
    ref.read(tripProvider.notifier).resetTrip();
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
                      color: AppTheme.primaryBlue.withValues(alpha: 0.02), // subtle tint
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

                              // Rating
                              Row(
                                children: [
                                  const Text('4.9', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                                  const SizedBox(width: 4),
                                  Icon(Icons.star, color: const Color(0xFFFF9500), size: 18),
                                ],
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
                                child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 30),
                              ),
                              const SizedBox(width: 16),
                              // Distance / Time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watch(tripProvider).currentTrip?.dropAddress ?? 'Rajeev Hospital',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(50)),
                                          child: Text(
                                            ref.watch(tripProvider).currentTrip?.distance ?? '2.4 km',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(width: 1, height: 16, color: const Color(0xFFDDE3EE)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(50)),
                                          child: Text(
                                            ref.watch(tripProvider).currentTrip?.duration ?? '8 min',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                                          ),
                                        ),
                                      ],
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
                                      ref.watch(tripProvider).currentTrip?.estimatedFare ?? '₹380',
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0040A0)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('+₹40 Surge', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFF9500))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Animated Route Preview
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
                                      Text(ref.watch(tripProvider).currentTrip?.dropAddress ?? 'Apollo Hospital', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                                      const SizedBox(height: 6),
                                      Text('Dropoff', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
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
                              // Decline (Smaller)
                              TextButton(
                                onPressed: _declineTrip,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                child: const Text('Decline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                              ),
                              const SizedBox(width: 16),
                              // Accept (Large, Prominent, Glowing)
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
                                        onPressed: _acceptTrip,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          elevation: 0,
                                        ),
                                        child: Row(
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
                                    // Circular Progress overlay around button (optional, or just use linear)
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
