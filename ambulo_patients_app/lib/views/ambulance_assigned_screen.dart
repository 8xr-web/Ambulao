import 'dart:async';
import 'dart:math';
import '../core/transitions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/booking_args.dart';
import '../viewmodels/booking_provider.dart';
import 'in_app_chat_screen.dart';
import 'ambulance_arrived_screen.dart';

class AmbulanceAssignedScreen extends StatefulWidget {
  final BookingArgs args;
  const AmbulanceAssignedScreen({super.key, required this.args});

  @override
  State<AmbulanceAssignedScreen> createState() => _AmbulanceAssignedScreenState();
}

class _AmbulanceAssignedScreenState extends State<AmbulanceAssignedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  Timer? _countdownTimer;
  int _remainingSeconds = 1 * 60; // 1 minute

  Offset _startPos = Offset.zero;
  Offset _endPos = Offset.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(vsync: this, duration: const Duration(minutes: 1));
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        // Move to En Route screen taking over the root navigator
        Navigator.of(context, rootNavigator: true).pushReplacement(
          SmoothPageRoute(page: AmbulanceArrivedScreen(args: widget.args)),
        );
      }
    });
    
    _moveController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      _startPos = Offset(size.width * 0.15, size.height * 0.15);
      _endPos = Offset(size.width * 0.5, size.height * 0.35);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showToast("Unable to open phone dialer", isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981), // Success Green
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rotation angle for the van mapping based on straight line path
    final double angle = atan2(_endPos.dy - _startPos.dy, _endPos.dx - _startPos.dx);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // 1. Map Background
          Positioned(
            top: 0, left: 0, right: 0,
            bottom: MediaQuery.of(context).size.height * 0.35, // Adjust to leave space for sheet
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // Use a map image to simulate maps plugin
                  image: NetworkImage('https://static-maps.yandex.ru/1.x/?lang=en_US&ll=78.3813,17.4398&z=13&l=map&size=600,600'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // 2. Route Line
          if (_initialized)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _moveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RoutePainter(_startPos, _endPos, _moveController.value),
                  );
                },
              ),
            ),

          // User Destination (Blue dot)
          if (_initialized)
            Positioned(
              left: _endPos.dx - 12,
              top: _endPos.dy - 12,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))
                  )
                )
              ),
            ),

          // Sliding Ambulance Icon (Van)
          if (_initialized)
            AnimatedBuilder(
              animation: _moveController,
              builder: (context, child) {
                final currentPos = Offset.lerp(_startPos, _endPos, _moveController.value)!;
                return Positioned(
                  left: currentPos.dx - 16,
                  top: currentPos.dy - 24,
                  child: _buildAmbulanceIcon(angle),
                );
              },
            ),
          
          // Back Button Layer
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                // Set active booking in provider so home shows banner
                context.read<BookingProvider>().setActiveAmbulanceBooking(
                  ambulanceType: widget.args.ambulanceType,
                  etaMinutes: (_remainingSeconds / 60).ceil(),
                  driverName: 'Rajesh Kumar',
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: const Center(child: Icon(Icons.arrow_back, color: AppColors.textPrimary)),
              ),
            ),
          ),

          // 3. Draggable Scrollable Sheet (Fix 6)
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.25,
            maxChildSize: 0.75,
            snap: true,
            snapSizes: const [0.25, 0.38, 0.75],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Handle (Fix 6)
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 48, height: 5,
                        decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2.5)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Section 1: Driver + ETA Blue Card (Fix 5)
                      _buildDriverETACard(),
                      const SizedBox(height: 24),
                      
                      // Section 2: OTP Box
                      _buildOTPBox(),
                      const SizedBox(height: 16),

                      if (widget.args.forPhone != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Booking for: +91 ${widget.args.forPhone}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Section 3: Action Buttons (Fix 7)
                      Row(
                        children: [
                          Expanded(child: _buildActionButton(Icons.call, "Call", () => _callNumber('+918309249445'))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildActionButton(Icons.chat_bubble_outline, "Chat", () {
                            Navigator.push(context, SmoothPageRoute(page: const InAppChatScreen()));
                          })),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<BookingProvider>().clearActiveAmbulanceBooking();
                            Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF04438), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          child: const Text('Cancel Booking', style: TextStyle(color: Color(0xFFF04438), fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 4: Notification Row
                      _buildNotificationRow(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceIcon(double angle) {
    return Transform.rotate(
      angle: angle + pi / 2, // adjust depending on the van's default orientation
      child: Container(
        width: 32, height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            // Siren
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: 4, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 2),
                Container(width: 8, height: 4, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
              ],
            ),
            const Spacer(),
            // Red Cross
            const Icon(Icons.add, color: Colors.red, size: 24),
            const Spacer(),
            // Back window
            Container(width: 20, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverETACard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A6FE8), borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left column (Driver details)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initials circle
                Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: Text("RK", style: TextStyle(color: Color(0xFF1A6FE8), fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text("Rajesh Kumar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            _buildAmbulanceBadge(widget.args.ambulanceType),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("⭐ 4.9 · 247 rides", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                        const SizedBox(height: 8),
                        const Text("TG 09 AB 1234", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(_getAmbulanceModel(widget.args.ambulanceType), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Right column (ETA)
          Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               const Text("Arriving in", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
               const SizedBox(height: 4),
               Text(
                 "${(_remainingSeconds / 60).ceil()} min", 
                 style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
               ),
               const SizedBox(height: 8),
               // Circular progress arc
               SizedBox(
                 width: 24, height: 24,
                 child: CircularProgressIndicator(
                   value: _remainingSeconds / (1 * 60),
                   strokeWidth: 3,
                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                   backgroundColor: Colors.white.withValues(alpha: 0.2),
                 ),
               ),
             ],
          )
        ],
      ),
    );
  }

  Widget _buildOTPBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Share this OTP with the paramedic", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ["7", "4", "2", "9"].map((digit) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 52, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF1A6FE8), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(digit, style: const TextStyle(color: Color(0xFF1A6FE8), fontSize: 26, fontWeight: FontWeight.bold))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text("Paramedic enters this OTP to start your journey", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Text("✅", style: TextStyle(fontSize: 16)),
          SizedBox(width: 12),
          Expanded(child: Text("Priya & Ravi have been notified", style: TextStyle(color: Color(0xFF065F46), fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildAmbulanceBadge(String type) {
    Color badgeColor;
    String label;
    switch (type) {
      case 'ALS':
        badgeColor = const Color(0xFF003366);
        label = 'ALS';
        break;
      case 'Bike':
        badgeColor = const Color(0xFF10B981);
        label = 'Ambu Bike';
        break;
      case 'LastRide':
        badgeColor = const Color(0xFF6B7280);
        label = 'Last Ride';
        break;
      default:
        badgeColor = const Color(0xFF1A6FE8);
        label = 'BLS';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  String _getAmbulanceModel(String type) {
    if (type == 'Bike') return 'Honda Activa 6G (Ambu Bike)';
    if (type == 'LastRide') return 'Force Traveller Mortuary Van';
    return 'Mahindra Bolero Ambulance';
  }
}

class RoutePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double progress;

  RoutePainter(this.start, this.end, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw full path faded
    canvas.drawLine(start, end, paint..color = AppColors.primaryBlue.withValues(alpha: 0.3));

    // Draw active path from ambulance to destination
    final currentPos = Offset.lerp(start, end, progress)!;
    canvas.drawLine(currentPos, end, paint..color = AppColors.primaryBlue);
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
