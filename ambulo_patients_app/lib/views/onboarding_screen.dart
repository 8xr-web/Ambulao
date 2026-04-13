import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'main_layout.dart';
import '../core/transitions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _getOTP() {
    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.length == 10) {
      Navigator.push(context, SmoothPageRoute(page: OTPScreen(phoneNumber: '+91 ${_phoneController.text}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 10-digit number'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A6FE8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pushReplacement(SmoothPageRoute(page: const MainLayout()));
  }

  void _googleSignIn() {
    // Google OAuth placeholder â€” shows coming soon
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Google Sign-In coming soon!', style: TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A6FE8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // â”€â”€ Blue top area â”€â”€
          Container(
            height: size.height * 0.52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A6FE8), Color(0xFF2E86FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // â”€â”€ White card bottom (rises 30px into blue area) â”€â”€
          Positioned(
            top: size.height * 0.52 - 30,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
            ),
          ),

          // â”€â”€ Content â”€â”€
          SafeArea(
            child: Column(
              children: [
                // â”€â”€ Ambulaice icon + branding in blue area â”€â”€
                Expanded(
                  flex: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ambulance icon
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Center(child: Icon(Icons.local_shipping, color: Colors.white, size: 46)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ambulao',
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text('Emergency care, one tap away',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),

                // â”€â”€ Login card content â”€â”€
                Expanded(
                  flex: 54,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter your mobile number',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A0F1E), letterSpacing: -0.4)),
                        const SizedBox(height: 4),
                        const Text("We'll send you a verification code",
                          style: TextStyle(color: Color(0xFF6B7A99), fontSize: 14)),
                        const SizedBox(height: 20),

                        // Phone Input Row
                        Row(children: [
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(child: Text('ðŸ‡®ðŸ‡³ +91', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A0F1E)))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A0F1E)),
                                decoration: const InputDecoration(
                                  hintText: 'Mobile number',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400, fontSize: 14),
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),

                        // Send OTP button â€” always full solid blue
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: _getOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A6FE8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // â”€â”€ or divider â”€â”€
                        Row(children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        ]),
                        const SizedBox(height: 18),

                        // â”€â”€ Continue with Google â”€â”€
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: OutlinedButton(
                            onPressed: _googleSignIn,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.white,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google G logo (manual colored text approach â€” no package needed)
                                _GoogleLogo(),
                                SizedBox(width: 12),
                                Text('Continue with Google', style: TextStyle(color: Color(0xFF1F2937), fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Continue as Guest
                        Center(
                          child: GestureDetector(
                            onTap: _continueAsGuest,
                            child: const Text('Continue as Guest for Emergency',
                              style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text('Your number is only used for booking',
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                        ),
                      ],
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

/// Google "G" rendered as overlapping colored segments using CustomPainter
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22, height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Draw circle segments: blue(top), red(bottom-right), yellow(bottom-left), green(right)
    final sweeps = <(double, double, Color)>[
      (-90, 135, const Color(0xFF4285F4)), // Blue top-right arc
      (45, 90, const Color(0xFF34A853)),   // Green right
      (135, 90, const Color(0xFFFBBC05)),  // Yellow bottom
      (225, 90, const Color(0xFFEA4335)),  // Red left
    ];

    for (final (start, sweep, color) in sweeps) {
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(Rect.fromCircle(center: c, radius: r), start * 3.14159 / 180, sweep * 3.14159 / 180, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    // White inner circle
    canvas.drawCircle(c, r * 0.55, Paint()..color = Colors.white);

    // Blue horizontal bar
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(c.dx, c.dy - r * 0.18, r, r * 0.36), barPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.5, c.dy), r * 0.55 * 0.6, Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(c.dx, c.dy - r * 0.18, r * 0.5, r * 0.36), Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
