import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/transitions.dart';
import '../models/booking_args.dart';
import '../viewmodels/user_provider.dart';
import 'searching_screen.dart';

class PanicModeScreen extends StatefulWidget {
  const PanicModeScreen({super.key});

  @override
  State<PanicModeScreen> createState() => _PanicModeScreenState();
}

class _PanicModeScreenState extends State<PanicModeScreen> with TickerProviderStateMixin {
  double _progress = 0.0;
  bool _isHolding = false;
  Timer? _holdTimer;

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    setState(() { _isHolding = true; _progress = 0.0; });
    _holdTimer?.cancel();
    int step = 0;
    _holdTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isHolding) { timer.cancel(); return; }
      step++;
      setState(() => _progress = step / 100.0);
      if (step >= 100) { timer.cancel(); _onHoldComplete(); }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    if (_progress > 0.0 && _progress < 1.0) _shakeController.forward(from: 0.0);
    setState(() { _isHolding = false; _progress = 0.0; });
  }

  void _onHoldComplete() {
    final user = context.read<UserProvider>();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      SmoothPageRoute(
        page: SearchingScreen(
          args: BookingArgs(
            ambulanceType: 'ALS', 
            pickup: user.address, 
            destination: 'Nearest Hospital',
            lat: user.latitude,
            lng: user.longitude,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header row ──
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Blue shield (left)
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Icon(Icons.security, color: Color(0xFF1A6FE8), size: 22)),
                    ),
                    // X close (right)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                        child: const Center(child: Icon(Icons.close, color: Color(0xFF6B7A99), size: 20)),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title ──
              const SizedBox(height: 16),
              const Text(
                "Emergency Panic\nMode",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0A0F1E), letterSpacing: -1, height: 1.1),
              ),

              // ── Description ──
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: const Text(
                  "Hold the button below to instantly alert emergency services and dispatch the nearest ICU ambulance to your location.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7A99), height: 1.5, fontWeight: FontWeight.w500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Hold Button ──
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) {
                  final double shakeX = _shakeController.isAnimating ? 8.0 * (0.5 - _shakeAnim.value).abs() * 4 * (_shakeAnim.value < 0.5 ? 1 : -1) : 0.0;
                  return Transform.translate(offset: Offset(shakeX, 0), child: child);
                },
                child: GestureDetector(
                  onTapDown: (_) => _startHold(),
                  onTapUp: (_) => _cancelHold(),
                  onTapCancel: _cancelHold,
                  child: SizedBox(
                    width: 200, height: 200,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        final double t1 = _pulseController.value;
                        final double t2 = (_pulseController.value + 0.5) % 1.0;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            Transform.scale(
                              scale: 1.0 + 0.38 * t1,
                              child: Opacity(
                                opacity: (0.45 - 0.45 * t1).clamp(0.0, 1.0),
                                child: Container(
                                  width: 180, height: 180,
                                  decoration: BoxDecoration(color: const Color(0xFF1A6FE8).withValues(alpha: 0.14), shape: BoxShape.circle),
                                ),
                              ),
                            ),
                            // Inner pulse ring
                            Transform.scale(
                              scale: 1.0 + 0.32 * t2,
                              child: Opacity(
                                opacity: (0.4 - 0.4 * t2).clamp(0.0, 1.0),
                                child: Container(
                                  width: 180, height: 180,
                                  decoration: BoxDecoration(color: const Color(0xFF1A6FE8).withValues(alpha: 0.18), shape: BoxShape.circle),
                                ),
                              ),
                            ),
                            // Progress ring
                            SizedBox(
                              width: 150, height: 150,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth: 4.5,
                                backgroundColor: const Color(0xFF1A6FE8).withValues(alpha: 0.10),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A6FE8)),
                              ),
                            ),
                            // Blue lightning square
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A6FE8),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: const Color(0xFF1A6FE8).withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 5))],
                              ),
                              child: const Center(child: Icon(Icons.bolt, color: Colors.white, size: 40)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Labels ──
              const SizedBox(height: 6),
              const Text("Hold for emergency", textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF1A6FE8), fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              const Text("Release to cancel", textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w400)),

              // ── Automated Protocol Card ──
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34, height: 34, margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(color: const Color(0xFF1A6FE8), borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Icon(Icons.info_outline, color: Colors.white, size: 18)),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Automated protocol", style: TextStyle(color: Color(0xFF1A6FE8), fontWeight: FontWeight.w600, fontSize: 13)),
                          SizedBox(height: 3),
                          Text(
                            "Activating panic mode bypasses confirmation and sends your medical profile and GPS data to the nearest responder immediately.",
                            style: TextStyle(color: Color(0xFF1A6FE8), fontSize: 13, height: 1.4, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom Buttons ──
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_in_talk_outlined, color: Color(0xFFF04438), size: 18),
                      label: const Text("Call Police", style: TextStyle(color: Color(0xFF0A0F1E), fontWeight: FontWeight.w600, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF1A6FE8), size: 18),
                      label: const Text("Health Info", style: TextStyle(color: Color(0xFF0A0F1E), fontWeight: FontWeight.w600, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
