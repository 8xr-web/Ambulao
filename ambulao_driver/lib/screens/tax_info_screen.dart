import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class TaxInfoScreen extends StatefulWidget {
  const TaxInfoScreen({super.key});
  @override
  State<TaxInfoScreen> createState() => _TaxInfoScreenState();
}

class _TaxInfoScreenState extends State<TaxInfoScreen> {
  final _gstCtrl = TextEditingController(text: '27AAAAA0000A1Z5');
  final _panCtrl = TextEditingController(text: 'AAAAA0000A');
  bool _editMode = false;

  @override
  void dispose() { _gstCtrl.dispose(); _panCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)), onPressed: () => Navigator.pop(context)),
        title: const Text('Tax Info', style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _editMode = !_editMode),
            child: Text(_editMode ? 'Cancel' : 'Edit',
                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tax Identifiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
          const SizedBox(height: 16),
          _buildField('GST Number', _gstCtrl, enabled: _editMode),
          const SizedBox(height: 14),
          _buildField('PAN Number', _panCtrl, enabled: _editMode),
          if (_editMode) ...[
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () { setState(() => _editMode = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tax info saved'), behavior: SnackBarBehavior.floating)); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              )),
          ],
          const SizedBox(height: 28),
          const Text('Tax Statements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
          const SizedBox(height: 16),
          ...[('FY 2025–26', 'Mar 2026'), ('FY 2024–25', 'Mar 2025')].map((t) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
            child: Row(children: [
              const Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                Text('Generated ${t.$2}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started'), behavior: SnackBarBehavior.floating)),
                child: const Text('Download', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool enabled = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE8F2FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: enabled ? AppTheme.primaryBlue : const Color(0xFFDDE3EE), width: enabled ? 2 : 1)),
        child: TextField(controller: ctrl, enabled: enabled,
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
      ),
    ]);
  }
}
