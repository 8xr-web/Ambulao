import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/app_strings.dart';
import '../core/transitions.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  // Controllers for 4 digits
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOTP() {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length == 4) {
      // Mock verification success
      Navigator.pushAndRemoveUntil(
        context,
        SmoothPageRoute(page: const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.enterValidCode)),
      );
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field (backspace)
      _focusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index == 3) {
      // Last digit entered, dismiss keyboard or optional auto-verify
      _focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.verifyPhoneTitle,
                      style: AppTextStyles.customH1Text,
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.customSubtH7GrayText,
                        children: [
                          const TextSpan(text: AppStrings.codeSentTo),
                          TextSpan(
                              text: widget.phoneNumber,
                              style: AppTextStyles.customBodyTextBold),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // OTP Inputs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 60,
                          height: 60,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (value) => _onDigitChanged(index, value),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              counterText: "",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryBlue, width: 2),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: AppTextStyles.customCaptionText,
                        children: [
                          TextSpan(text: AppStrings.didNotReceiveCode),
                          TextSpan(
                            text: AppStrings.requestAgain,
                            style: TextStyle(decoration: TextDecoration.underline, color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Verify Button
                    CustomButton(
                      text: AppStrings.verifyAndCreateAccount,
                      onPressed: _verifyOTP,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
