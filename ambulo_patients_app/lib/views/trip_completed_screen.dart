import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_args.dart';
import 'main_layout.dart';
import '../core/transitions.dart';
import 'faq_screen.dart';

class TripCompletedScreen extends StatefulWidget {
  final BookingArgs args;
  const TripCompletedScreen({super.key, required this.args});

  @override
  State<TripCompletedScreen> createState() => _TripCompletedScreenState();
}

class _TripCompletedScreenState extends State<TripCompletedScreen> {
  int _selectedPayment = 0; // 0=UPI, 1=Ayushman, 2=Corporate, 3=Cash
  int _rating = 4;
  int? _selectedTip; // tip amount in Rs
  bool _showCustomTip = false;
  bool _reviewSubmitted = false;
  final TextEditingController _customTipCtrl = TextEditingController();
  final TextEditingController _commentCtrl = TextEditingController();

  void _submitReview() {
    setState(() => _reviewSubmitted = true);
    _toast('Review submitted. Thank you! 🙏');
  }


  int get _tipAmount {
    if (_showCustomTip) return int.tryParse(_customTipCtrl.text) ?? 0;
    return _selectedTip ?? 0;
  }

  String get _totalDisplay {
    final base = int.tryParse(widget.args.fare.replaceAll('₹', '').replaceAll(',', '')) ?? 0;
    return '₹${base + _tipAmount}';
  }

  @override
  void dispose() {
    _customTipCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? Icons.check_circle : Icons.info_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold))),
      ]),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: success ? const Color(0xFF12B76A) : const Color(0xFF1A6FE8),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _callSupport(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _toast('Unable to open phone dialer', success: false);
    }
  }

  void _confirmPayment() {
    _toast('Payment successful! ✅ Receipt sent to your email.');
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        SmoothPageRoute(page: const MainLayout()),
        (route) => false,
      );
    });
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
            const SizedBox(height: 20),
            _buildHelpOption(Icons.phone_outlined, 'Call Support', 'Speak with our team', () { Navigator.pop(context); _callSupport('+918186960072'); }),
            const SizedBox(height: 12),
            _buildHelpOption(Icons.chat_outlined, 'WhatsApp', 'Chat on WhatsApp', () { Navigator.pop(context); _toast('Opening WhatsApp...'); }),
            const SizedBox(height: 12),
            _buildHelpOption(Icons.help_outline, 'FAQ', 'Browse common questions', () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true).push(
                SmoothPageRoute(page: const FaqScreen()),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF1A6FE8), size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A0F1E))),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
            ])),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF0A0F1E), size: 20)),
                  ),
                  const SizedBox(width: 16),
                  const Text('Payment & Billing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // Trip Completed Hero
                    _buildTripHero(),
                    const SizedBox(height: 16),

                    // Total Amount (updates with tip)
                    _buildTotalAmountCard(),
                    const SizedBox(height: 16),

                    // Fare Breakdown
                    _buildFareBreakdownCard(),
                    const SizedBox(height: 24),

                    // Payment Method
                    _buildPaymentSection(),
                    const SizedBox(height: 24),

                    // Tipping Section
                    _buildTipSection(),
                    const SizedBox(height: 24),

                    // Rating + Comment
                    _buildRatingSection(),
                    const SizedBox(height: 130),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A6FE8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0),
                child: const Text('Pay & Get Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton(
                onPressed: _showHelpSheet,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Help & Support', style: TextStyle(color: Color(0xFF1A6FE8), fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHero() => Column(children: [
    Container(width: 72, height: 72,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF12B76A), width: 2.5)),
      child: const Icon(Icons.check_rounded, color: Color(0xFF12B76A), size: 40)),
    const SizedBox(height: 16),
    const Text('Trip Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
    const SizedBox(height: 6),
    const Text('Thank you for choosing Ambulao', style: TextStyle(fontSize: 14, color: Color(0xFF6B7A99))),
  ]);

  Widget _buildTotalAmountCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
    decoration: BoxDecoration(color: const Color(0xFF1A6FE8), borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 10),
      Text(_totalDisplay, style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.0)),
      const SizedBox(height: 6),
      Text(widget.args.serviceName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    ]),
  );

  Widget _buildFareBreakdownCard() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      _buildFareRow('Distance', '3.2 km'),
      const Divider(height: 1, color: Color(0xFFF0F2F5)),
      _buildFareRow('Duration', '18 min'),
      const Divider(height: 1, color: Color(0xFFF0F2F5)),
      _buildFareRow('Base Fare', widget.args.fare),
      const Divider(height: 1, color: Color(0xFFF0F2F5)),
      _buildFareRow('GST (5%)', '₹49'),
      const Divider(height: 1, color: Color(0xFFF0F2F5)),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildLocationRow(Icons.location_on_outlined, widget.args.pickup),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.local_hospital_outlined, widget.args.destination.split(',')[0], filled: true),
        ]),
      ),
    ]),
  );

  Widget _buildFareRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 14)),
      Text(value, style: const TextStyle(color: Color(0xFF0A0F1E), fontSize: 14, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _buildLocationRow(IconData icon, String text, {bool filled = false}) => Row(children: [
    Container(width: 36, height: 36,
      decoration: BoxDecoration(color: filled ? const Color(0xFF1A6FE8) : const Color(0xFFEEF4FF), shape: BoxShape.circle),
      child: Icon(icon, color: filled ? Colors.white : const Color(0xFF1A6FE8), size: 18)),
    const SizedBox(width: 12),
    Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF0A0F1E), fontSize: 13, fontWeight: FontWeight.w500))),
  ]);

  Widget _buildPaymentSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
      const SizedBox(height: 12),
      _buildPaymentOption(0, Icons.smartphone_outlined, 'UPI Payment', 'PhonePe / GPay / Paytm'),
      const SizedBox(height: 10),
      _buildPaymentOption(1, Icons.shield_outlined, 'Ayushman Bharat / CGHS', 'Card linked'),
      const SizedBox(height: 10),
      _buildPaymentOption(2, Icons.business_center_outlined, 'Corporate Billing', 'Office Account'),
      const SizedBox(height: 10),
      _buildPaymentOption(3, Icons.payments_outlined, 'Cash', 'Pay the driver in cash'),
    ],
  );

  Widget _buildPaymentOption(int index, IconData icon, String title, String subtitle) {
    final bool sel = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? const Color(0xFF1A6FE8) : const Color(0xFFEEF4FF), width: sel ? 1.8 : 1.0),
        ),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: sel ? const Color(0xFF1A6FE8) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: sel ? Colors.white : const Color(0xFF6B7A99), size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A0F1E))),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
          ])),
          if (sel) Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFF1A6FE8), shape: BoxShape.circle),
            child: const Icon(Icons.circle, color: Color(0xFF1A6FE8), size: 12)),
        ]),
      ),
    );
  }

  Widget _buildTipSection() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Add a tip for your paramedic', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
      const SizedBox(height: 14),
      Row(children: [
        _buildTipPill(20),
        const SizedBox(width: 8),
        _buildTipPill(50),
        const SizedBox(width: 8),
        _buildTipPill(100),
        const SizedBox(width: 8),
        _buildCustomTipPill(),
      ]),
      if (_showCustomTip) ...[
        const SizedBox(height: 12),
        TextField(
          controller: _customTipCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Enter amount (₹)',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixText: '₹ ',
            filled: true, fillColor: const Color(0xFFF8FAFF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD6E4FF))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
      const SizedBox(height: 10),
      const Text('100% goes to your paramedic', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
    ]),
  );

  Widget _buildTipPill(int amount) {
    final sel = !_showCustomTip && _selectedTip == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _selectedTip = amount; _showCustomTip = false; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF1A6FE8) : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: sel ? const Color(0xFF1A6FE8) : const Color(0xFFD6E4FF)),
          ),
          child: Center(child: Text('₹$amount', style: TextStyle(color: sel ? Colors.white : const Color(0xFF1A6FE8), fontWeight: FontWeight.bold, fontSize: 13))),
        ),
      ),
    );
  }

  Widget _buildCustomTipPill() {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _showCustomTip = true; _selectedTip = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _showCustomTip ? const Color(0xFF1A6FE8) : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _showCustomTip ? const Color(0xFF1A6FE8) : const Color(0xFFD6E4FF)),
          ),
          child: Center(child: Text('Custom', style: TextStyle(color: _showCustomTip ? Colors.white : const Color(0xFF1A6FE8), fontWeight: FontWeight.bold, fontSize: 13))),
        ),
      ),
    );
  }

  Widget _buildRatingSection() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      const Text('Rate your experience', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final filled = i < _rating;
          return GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded, color: filled ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB), size: 36)),
          );
        }),
      ),
      const SizedBox(height: 16),
      // Comment label
      const Align(
        alignment: Alignment.centerLeft,
        child: Text('Write a comment (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7A99))),
      ),
      const SizedBox(height: 6),
      // Comment box
      TextField(
        controller: _commentCtrl,
        maxLines: 3,
        maxLength: 200,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Share your experience with the driver and service...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          filled: true, fillColor: const Color(0xFFF8FAFF),
          counterStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD6E4FF))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5)),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
      const SizedBox(height: 12),
      // Submit Review button
      if (!_reviewSubmitted)
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: _rating > 0 ? _submitReview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _rating > 0 ? const Color(0xFF1A6FE8) : const Color(0xFFD1D5DB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 8),
            Text('Review submitted', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
        ),
    ]),
  );
}
