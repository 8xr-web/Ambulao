import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/permissions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  const OtpScreen({super.key, required this.phone, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendSeconds = 42;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4) {
      _verify();
    }
  }

  void _verify() async {
    setState(() => _isVerifying = true);
    
    final otp = _controllers.map((c) => c.text).join();
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otp,
    );

    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // Save session flag for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('driver_uid', user.uid);
        await prefs.setBool('is_logged_in', true);
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PermissionsScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      
      String msg = e.message ?? 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        msg = 'Wrong OTP. Please try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1F44),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to ${widget.phone}',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (i) => SizedBox(
                    width: 72,
                    height: 72,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A1F44),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Verify button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Resend
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() => _resendSeconds = 42);
                          _startTimer();
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
