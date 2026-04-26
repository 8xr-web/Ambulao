import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewmodels/auth_view_model.dart';
import '../core/transitions.dart';
import 'main_layout.dart';
import 'package:flutter_hello_world/localisation/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isSending = false;

  bool get _canSubmit => _phoneController.text.length == 10 && !_isSending;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_canSubmit) return;
    setState(() => _isSending = true);

    final phone = '+91${_phoneController.text.trim()}';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval on Android (only on real devices)
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() => _isSending = false);
        String msg = 'Verification failed. Please try again.';
        if (e.code == 'invalid-phone-number') {
          msg = 'This number is not registered for access.';
        } else if (e.code == 'too-many-requests') {
          msg = 'Too many attempts. Please try again later.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() => _isSending = false);
        Navigator.push(
          context,
          SmoothPageRoute(
            page: OtpScreen(
              phone: _phoneController.text.trim(),
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // No-op — user will type OTP manually
      },
    );
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('patient_uid', user.uid);
        await prefs.setString(
            'patient_phone', user.phoneNumber ?? '');
        await prefs.setInt(
            'session_created_at',
            DateTime.now().millisecondsSinceEpoch);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(page: const MainLayout()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A3AAD),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // TOP BLUE SECTION — 45% of screen
          Container(
            height: screenHeight * 0.45,
            width: double.infinity,
            color: const Color(0xFF0A3AAD),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A6FE8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                      children: [
                        TextSpan(text: 'Ambu'),
                        TextSpan(
                          text: 'lao',
                          style: TextStyle(color: Color(0xFF60A5FA)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Emergency care, one tap away',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // WHITE CARD SECTION
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.enterMobileNumber,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0F1E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "We'll send you a verification code",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7A99),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Phone input row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'IN  +91',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A0F1E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              onChanged: (_) => setState(() {}),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF0A0F1E),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Mobile number',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B8CC),
                                  fontWeight: FontWeight.w500,
                                ),
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Send OTP button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _canSubmit ? _sendOtp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSubmit
                                ? const Color(0xFF1A6FE8)
                                : const Color(0xFF98B8EB),
                            disabledBackgroundColor: const Color(0xFF98B8EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.sendOtp,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // OR divider
                      const Row(
                        children: [
                          Expanded(
                              child: Divider(color: Color(0xFFE8EFF8))),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Color(0xFF9AA5BE),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: Color(0xFFE8EFF8))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                                color: Color(0xFFE0E0E0), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF4FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      color: Color(0xFF1A6FE8),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Color(0xFF0A0F1E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Guest emergency link
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await context
                                .read<AuthViewModel>()
                                .continueAsGuest();
                            if (!context.mounted) return;
                            Navigator.of(context).pushReplacement(
                              SmoothPageRoute(
                                page: const MainLayout(),
                              ),
                            );
                          },
                          child: const Text(
                            'Continue as Guest for Emergency',
                            style: TextStyle(
                              color: Color(0xFFF04438),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      const Center(
                        child: Text(
                          'Your number is only used for booking',
                          style: TextStyle(
                            color: Color(0xFF9AA5BE),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final email =
        await context.read<AuthViewModel>().signInWithGoogle();
    if (email != null && mounted) {
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(
          page: const MainLayout(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Google sign in failed. Try again.')),
      );
    }
  }
}

// ─── OTP SCREEN ─────────────────────────────────────────────────────────────

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OtpScreen({
    required this.phone,
    required this.verificationId,
    super.key,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isVerifying = false;

  bool get _canVerify =>
      _controllers.every((c) => c.text.isNotEmpty) && !_isVerifying;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_canVerify) return;
    setState(() => _isVerifying = true);

    final otp = _controllers.map((c) => c.text).join();
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otp,
    );

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('patient_uid', user.uid);
        await prefs.setString('patient_phone', user.phoneNumber ?? '');
        await prefs.setInt('session_created_at', DateTime.now().millisecondsSinceEpoch);

        // ── Check if this is a new user ───────────────────────────────────
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        final savedName = prefs.getString('patient_name') ?? '';

        if (!mounted) return;

        if (isNewUser || savedName.isEmpty) {
          await _showNameSheet(user.uid, prefs);
        }
      }

      if (!mounted) return;

      // Update AuthViewModel BEFORE navigating — this lets AuthGateScreen
      // cleanly rebuild (showing LocationPermissionScreen) before we replace
      // the route, which prevents the _dependents.isEmpty assertion crash.
      await context.read<AuthViewModel>().signInWithOtpToken(user?.uid ?? 'otp');

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        SmoothPageRoute(page: const MainLayout()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);

      String msg;
      switch (e.code) {
        case 'invalid-verification-code':
          msg = 'Wrong OTP. Please try again.';
          break;
        case 'session-expired':
          msg = 'OTP expired. Please request a new one.';
          break;
        default:
          msg = e.message ?? 'Verification failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)),
        ),
      );
    }
  }

  /// Shows a bottom sheet asking the user their name (first time only).
  Future<void> _showNameSheet(String uid, SharedPreferences prefs) async {
    final nameCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is your name?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A0F1E)),
              ),
              const SizedBox(height: 6),
              const Text(
                "We'll use this to personalise your experience.",
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7A99)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (ctx, setSt) => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      // Save locally
                      await prefs.setString('patient_name', name);
                      await prefs.setString('user_name', name);
                      // Save to Firestore
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .set({'name': name, 'phone': prefs.getString('patient_phone') ?? ''}, SetOptions(merge: true));
                      } catch (_) {}
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6FE8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Save & Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF0A0F1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Number',
          style: TextStyle(
            color: Color(0xFF0A0F1E),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.enterOtp,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A0F1E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sent to +91 ${widget.phone}',
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF6B7A99)),
            ),
            const SizedBox(height: 32),

            // 6 OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => SizedBox(
                  width: 46,
                  height: 56,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A6FE8),
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFDDE3EF), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFDDE3EF), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1A6FE8), width: 2),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      if (val.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resend timer
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      'Resend OTP in ${_secondsLeft}s',
                      style: const TextStyle(
                          color: Color(0xFF9AA5BE), fontSize: 13),
                    )
                  : TextButton(
                      onPressed: () {
                        setState(() => _secondsLeft = 30);
                        _startTimer();
                      },
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Color(0xFF1A6FE8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Verify button
            Opacity(
              opacity: _canVerify ? 1.0 : 0.5,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _canVerify ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6FE8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
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
                          'Verify & Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
