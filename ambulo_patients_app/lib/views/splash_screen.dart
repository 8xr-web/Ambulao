import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'auth_gate_screen.dart';
import '../core/transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringsController;
  late final AnimationController _floatController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _navTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(page: const AuthGateScreen()),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ringsController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 19.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Container(
              color: const Color(0xFF0A3AAD),
              child: Stack(
                children: [
                  // Grid overlay
                  CustomPaint(
                    painter: _GridPainter(),
                    size: Size.infinite,
                  ),

                  // Radial glow behind logo
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF1A6FE8).withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Animated concentric rings
                  AnimatedBuilder(
                    animation: _ringsController,
                    builder: (context, child) {
                      final t = _ringsController.value;
                      return Positioned.fill(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildRing(140, t, 0.0),
                              _buildRing(190, t, 0.3),
                              _buildRing(240, t, 0.6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Center logo + text
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final dy = sin(_floatController.value * 2 * pi) * 6;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _LogoCard(),
                        const SizedBox(height: 28),
                        _TitleBlock(),
                      ],
                    ),
                  ),

                  // Bottom dots + text
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _dot(0.25),
                            const SizedBox(width: 6),
                            _dot(0.7),
                            const SizedBox(width: 6),
                            _dot(0.25),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'MADE FOR INDIA 🇮🇳',
                          style: TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRing(double baseSize, double t, double phase) {
    final progress = ((t + phase) % 1.0);
    final scale = 1.0 + 0.05 * progress;
    final opacity = 0.4 - 0.25 * progress;
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: baseSize,
          height: baseSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(double opacity) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.2),
        ),
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF1A6FE8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 118, 255, 0.5),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ambu',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'lao',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Color(0xFF60A5FA),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Emergency care, one tap away',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
