import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneNumberField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/330/330439.png', // India Flag Icon
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Container(height: 24, width: 1, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 1.2,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '00000 00000',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                _PhoneNumberFormatter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Formatter to add space after 5 digits
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 10) return oldValue;

    final newText = newValue.text;
    if (newText.length > 5) {
      return TextEditingValue(
        text: '${newText.substring(0, 5)} ${newText.substring(5)}',
        selection: TextSelection.collapsed(offset: newText.length + 1),
      );
    }
    return newValue;
  }
}
