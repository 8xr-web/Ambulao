import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class BugReporterScreen extends StatefulWidget {
  const BugReporterScreen({super.key});
  @override
  State<BugReporterScreen> createState() => _BugReporterScreenState();
}

class _BugReporterScreenState extends State<BugReporterScreen> {
  String? _category;
  final _descCtrl = TextEditingController();
  bool _submitted = false;

  final _categories = ['App Crash', 'UI Issue', 'Map / Navigation', 'Payment', 'Login / OTP', 'Trip Issue', 'Other'];

  @override
  void dispose() { _descCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (_category == null || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)), onPressed: () => Navigator.pop(context)),
        title: const Text('Bug Reporter', style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFFE0F7E9), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 56)),
      const SizedBox(height: 24),
      const Text('Report Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
      const SizedBox(height: 8),
      const Text('Our team will review your report\nand get back to you within 48 hours.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
      const SizedBox(height: 32),
      SizedBox(width: 200, height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
        )),
    ]));
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Report an Issue', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
        const SizedBox(height: 6),
        const Text('Help us improve AMBULAO by reporting bugs.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        const Text('Issue Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10,
          children: _categories.map((c) {
            final sel = c == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: sel ? AppTheme.primaryBlue : const Color(0xFFDDE3EE), width: 1.5)),
                child: Text(c, style: TextStyle(color: sel ? Colors.white : const Color(0xFF0A1F44), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            );
          }).toList()),
        const SizedBox(height: 20),
        const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: _descCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe the issue in detail...',
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            contentPadding: const EdgeInsets.all(16)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF0A1F44))),
        const SizedBox(height: 20),
        // Attach screenshot placeholder
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker not available on web demo'), behavior: SnackBarBehavior.floating)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDE3EE))),
            child: Row(children: const [
              Icon(Icons.attach_file, color: AppTheme.primaryBlue),
              SizedBox(width: 12),
              Text('Attach Screenshot (optional)', style: TextStyle(fontSize: 14, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
            child: const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          )),
      ]),
    );
  }
}
