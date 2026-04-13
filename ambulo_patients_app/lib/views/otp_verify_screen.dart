import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../viewmodels/auth_view_model.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneDigits;
  const OtpVerifyScreen({super.key, required this.phoneDigits});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _seconds = 30;
  String? _error;

  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();


  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _nodes[index].unfocus();
    }
    if (_error != null) setState(() => _error = null);
    setState(() {});
  }

  Future<void> _verify() async {
    final otp = _otp;
    if (otp.length != 6) return;

    // Stub: accept 123456
    if (otp != '123456') {
      setState(() => _error = 'Invalid OTP');
      _shakeCtrl.forward(from: 0);
      return;
    }
    await context.read<AuthViewModel>().signInWithOtpToken('demo_token');
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _resend() {
    setState(() {
      _seconds = 30;
      _error = null;
      for (final c in _ctrls) {
        c.clear();
      }
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
    _nodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                'Code sent to +91 ${widget.phoneDigits}',
                style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 26),
              AnimatedBuilder(
                animation: shake,
                builder: (context, child) {
                  final double dx = _shakeCtrl.isAnimating
                      ? (8 * (0.5 - shake.value).abs() * 2).toDouble()
                      : 0.0;
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (v) => _onChanged(i, v),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text("Resend OTP", style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  if (_seconds > 0)
                    Text('in 00:${_seconds.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700))
                  else
                    TextButton(
                      onPressed: _resend,
                      child: const Text('Resend OTP', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Opacity(
                  opacity: _otp.length == 6 ? 1.0 : 0.5,
                  child: ElevatedButton(
                    onPressed: _otp.length == 6 ? _verify : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Verify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

