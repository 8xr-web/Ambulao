import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';

class ChangePhoneNumberScreen extends StatefulWidget {
  const ChangePhoneNumberScreen({super.key});

  @override
  State<ChangePhoneNumberScreen> createState() => _ChangePhoneNumberScreenState();
}

class _ChangePhoneNumberScreenState extends State<ChangePhoneNumberScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  bool _otpSent = false;
  String? _phoneError;
  String? _otpError;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  bool get _isPhoneValid => _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length == 10;
  bool get _isOtpValid => _otpCtrl.text.replaceAll(RegExp(r'\D'), '').length == 6;

  void _sendOtp() {
    setState(() {
      _phoneError = _isPhoneValid ? null : AppStrings.enterValidNumber;
      if (_phoneError != null) return;
      _otpSent = true;
      _otpError = null;
    });
  }

  void _verifyOtp() {
    final otp = _otpCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (otp.length != 6) {
      setState(() => _otpError = AppStrings.invalidOtpTryAgain);
      return;
    }

    // Stub success rule: accept 123456
    final ok = otp == '123456';
    if (!ok) {
      setState(() => _otpError = AppStrings.invalidOtpTryAgain);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          AppStrings.phoneUpdatedSuccess,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
        ),
        title: const Text(
          AppStrings.changePhoneNumber,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                '${AppStrings.currentNumberLabel} +91 98765 43210',
                style: TextStyle(color: Color(0xFF6B7A99), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.newMobileNumberLabel,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _phoneField(),
            if (_phoneError != null) ...[
              const SizedBox(height: 6),
              Text(_phoneError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: const Text(
                  AppStrings.sendOtp,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 24),
              const Text(
                'Enter OTP',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _otpField(),
              if (_otpError != null) ...[
                const SizedBox(height: 6),
                Text(_otpError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Opacity(
                  opacity: _isOtpValid ? 1.0 : 0.5,
                  child: ElevatedButton(
                    onPressed: _isOtpValid ? _verifyOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: const Text(
                      AppStrings.verifyUpdate,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '+91',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  setState(() => _phoneError = _isPhoneValid ? null : AppStrings.enterValidNumber);
                }
              },
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter mobile number',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '••••••',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        ),
        onChanged: (_) {
          if (_otpError != null) setState(() => _otpError = null);
          setState(() {}); // update button state
        },
      ),
    );
  }
}

