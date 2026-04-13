import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../viewmodels/booking_provider.dart';
import '../viewmodels/user_provider.dart';
import 'main_layout.dart';

/// Screen shown after nurse booking is confirmed.
/// Triggered by: NurseSearchingScreen → navigate here after "nurse found".
class NurseAssignedScreen extends StatefulWidget {
  final String serviceLabel;
  final int durationHours;
  final String nurseName;
  final int totalPrice;

  const NurseAssignedScreen({
    super.key,
    required this.serviceLabel,
    required this.durationHours,
    required this.nurseName,
    required this.totalPrice,
  });

  @override
  State<NurseAssignedScreen> createState() => _NurseAssignedScreenState();
}

class _NurseAssignedScreenState extends State<NurseAssignedScreen> {
  late Timer _timer;
  Duration _remaining = const Duration(hours: 18, minutes: 42, seconds: 30);

  final String _bookingId = 'AMB-N-20260318-4821';
  bool _bookingAdded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining = _remaining - const Duration(seconds: 1));
      } else {
        _timer.cancel();
      }
    });

    // Add booking to provider so it appears in Activity screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_bookingAdded && mounted) {
        final user = context.read<UserProvider>();
        context.read<BookingProvider>().addNurseBooking(
              NurseBooking(
                bookingId: _bookingId,
                nurseName: widget.nurseName,
                serviceLabel: widget.serviceLabel,
                durationHours: widget.durationHours,
                totalPrice: widget.totalPrice,
                location: user.address,
                scheduledDate: 'Tomorrow — Wed, 19 Mar 2026',
                startTime: '9:00 AM',
                endTime: '1:00 PM',
              ),
            );
        _bookingAdded = true;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => MainLayout.homeNavKey.currentState
                        ?.popUntil((r) => r.isFirst),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF4FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nurse Booking Confirmed',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Blue hero card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6FE8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                                width: 2,
                              ),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Booking Confirmed!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.nurseName} will arrive at your location\ntomorrow morning as scheduled.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Booking ID: $_bookingId',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Assigned Nurse ──
                    const Text(
                      'Assigned Nurse',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE8EFF8), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SP',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.nurseName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary),
                                    ),
                                    const Text(
                                      'General Care Nurse',
                                      style: TextStyle(
                                          color: Color(0xFF6B7A99),
                                          fontSize: 12),
                                    ),
                                    const Text(
                                      'INC Certified · 5 yrs exp · 312 sessions',
                                      style: TextStyle(
                                          color: Color(0xFF9AA5BE),
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF4FF),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      '✓ Verified',
                                      style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E7),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      '⭐ 4.9',
                                      style: TextStyle(
                                          color: Color(0xFF9A6C00),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFF0F4FA)),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              'General Care',
                              'ICU',
                              'Post-Surgery',
                              'Diabetic'
                            ]
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF4FF),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Schedule Details ──
                    const Text(
                      'Schedule Details',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE8EFF8), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F6FF),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: AppColors.primaryBlue, size: 14),
                                SizedBox(width: 8),
                                Text(
                                  'Scheduled for Tomorrow — Wed, 19 Mar 2026',
                                  style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _detailRow('Start Time', '9:00 AM',
                                    color: AppColors.primaryBlue),
                                _detailRow('Duration',
                                    '${widget.durationHours} hours (until 1:00 PM)'),
                                _detailRow('Service Type', widget.serviceLabel),
                                _detailRow('Location', context.read<UserProvider>().address),
                                _detailRow(
                                    'Total Amount', '₹${widget.totalPrice}',
                                    color: const Color(0xFF12B76A)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),



                    // ── Reminder banner ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE082),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.info_outline,
                                color: Color(0xFF7A6000), size: 16),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "You'll get a reminder",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF5A4500),
                                      fontSize: 12),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "We'll notify you 1 hour before Sunita arrives. Keep your door accessible and OTP ready.",
                                  style: TextStyle(
                                      color: Color(0xFF7A6000),
                                      fontSize: 11,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Call + Chat ──
                    Row(
                      children: [
                        Expanded(
                            child: _actionButton(Icons.phone_outlined,
                                'Call Nurse', 'Contact Sunita', _callNurse)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _actionButton(Icons.chat_bubble_outline,
                                'Chat', 'Message Sunita', () {})),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Notified row ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FBF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF12B76A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Priya & Ravi have been notified about this booking',
                              style: TextStyle(
                                  color: Color(0xFF0A7A45),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Cancel Booking ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _cancelBooking,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFF04438), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                        child: const Text(
                          'Cancel Booking',
                          style: TextStyle(
                              color: Color(0xFFF04438),
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }



  Widget _actionButton(
      IconData icon, String label, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: Color(0xFFEEF4FF), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Future<void> _callNurse() async {
    final uri = Uri.parse('tel:+919876543210');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _cancelBooking() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFEF4444), size: 40),
            const SizedBox(height: 12),
            const Text('Cancel Booking?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Cancellation after confirmation may incur charges.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7A99)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Keep it'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<BookingProvider>()
                          .removeNurseBooking(_bookingId);
                      Navigator.pop(context);
                      MainLayout.homeNavKey.currentState
                          ?.popUntil((r) => r.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


