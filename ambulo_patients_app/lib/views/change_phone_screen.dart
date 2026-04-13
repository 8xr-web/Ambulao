import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_provider.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});
  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _newPhoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _otpSent = false;
  int _secondsLeft = 30;
  Timer? _timer;

  bool get _canSend => _newPhoneController.text.length == 10;
  bool get _canVerify => _otpControllers.every((c) => c.text.isNotEmpty);

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft == 0) { t.cancel(); return; }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _newPhoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(children: [

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8EFF8), width: 1.5),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Color(0xFF0A0F1E)),
                ),
              ),
              const SizedBox(width: 14),
              const Text('Change Mobile Number',
                style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0F1E))),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Current number card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE8EFF8), width: 1.5),
                    ),
                    child: Row(children: [
                      const Icon(Icons.phone_outlined,
                        color: Color(0xFF9AA5BE), size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current number',
                            style: TextStyle(fontSize: 11,
                              color: Color(0xFF9AA5BE),
                              fontWeight: FontWeight.w500)),
                          Text('+91 ${context.read<UserProvider>().phone}',
                            style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A0F1E))),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  const Text('New mobile number',
                    style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7A99))),
                  const SizedBox(height: 8),

                  // New number input
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Text('IN +91',
                        style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A0F1E))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(
                      controller: _newPhoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !_otpSent,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter new number',
                        hintStyle: const TextStyle(color: Color(0xFFB0B8CC)),
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A6FE8), width: 1.5),
                        ),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Send OTP button
                  if (!_otpSent)
                    Opacity(
                      opacity: _canSend ? 1.0 : 0.5,
                      child: SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _canSend ? () {
                            setState(() {
                              _otpSent = true;
                              _secondsLeft = 30;
                            });
                            _startTimer();
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A6FE8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          ),
                          child: const Text('Send OTP',
                            style: TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),

                  // OTP input — shows after Send OTP tapped
                  if (_otpSent) ...[
                    const Text('Enter verification code',
                      style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7A99))),
                    const SizedBox(height: 4),
                    Text('Sent to +91 ${_newPhoneController.text}',
                      style: const TextStyle(fontSize: 12,
                        color: Color(0xFF9AA5BE))),
                    const SizedBox(height: 16),

                    // 6 OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) => SizedBox(
                        width: 46, height: 54,
                        child: TextField(
                          controller: _otpControllers[i],
                          focusNode: _otpFocusNodes[i],
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              _otpFocusNodes[i + 1].requestFocus();
                            }
                            if (val.isEmpty && i > 0) {
                              _otpFocusNodes[i - 1].requestFocus();
                            }
                            setState(() {});
                          },
                          style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A6FE8)),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A6FE8), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A6FE8), width: 2),
                            ),
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 16),

                    // Resend timer
                    Center(child: _secondsLeft > 0
                      ? Text('Resend OTP in ${_secondsLeft}s',
                          style: const TextStyle(color: Color(0xFF9AA5BE),
                            fontSize: 13))
                      : TextButton(
                          onPressed: () {
                            setState(() => _secondsLeft = 30);
                            _startTimer();
                          },
                          child: const Text('Resend OTP',
                            style: TextStyle(color: Color(0xFF1A6FE8),
                              fontWeight: FontWeight.w600)),
                        ),
                    ),
                    const SizedBox(height: 16),

                    // Verify & Update button
                    Opacity(
                      opacity: _canVerify ? 1.0 : 0.5,
                      child: SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _canVerify ? () {
                            // Update phone in Provider
                            context.read<UserProvider>()
                              .updatePhone(_newPhoneController.text);

                            // Show success toast
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(children: [
                                  Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Phone number updated successfully'),
                                ]),
                                backgroundColor: const Color(0xFF12B76A),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Go back to EditProfileScreen
                            Navigator.pop(context);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A6FE8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          ),
                          child: const Text('Verify & Update',
                            style: TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],

                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
