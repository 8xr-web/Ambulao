import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ambulao_driver/core/theme.dart';

class _Account {
  final String title;
  final String subtitle;
  final bool isBank;
  bool verified;
  _Account({required this.title, required this.subtitle, required this.isBank, this.verified = true});
}

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});
  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  int _activeIndex = 0;
  final List<_Account> _accounts = [
    _Account(title: 'HDFC Bank', subtitle: '•••• •••• 1234', isBank: true, verified: true),
    _Account(title: 'UPI Payment', subtitle: 'rayan@okaxis', isBank: false, verified: true),
  ];

  void _showToast(String msg, Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => _ToastBanner(message: msg, color: color, onRemove: () => entry.remove()));
    overlay.insert(entry);
  }

  void _switchAccount(int idx) {
    if (idx == _activeIndex) return;
    setState(() => _activeIndex = idx);
    _showToast('Primary account updated', AppTheme.primaryBlue);
  }

  void _showAddAccountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAccountSheet(
        onSaved: (account) {
          setState(() => _accounts.add(account));
        },
        onToast: _showToast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bank / UPI Details',
            style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary payout label
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Primary Payout Method', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        Text(
                          _accounts.isNotEmpty ? _accounts[_activeIndex].title : 'None',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Linked Accounts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
            const SizedBox(height: 16),
            ..._accounts.asMap().entries.map((e) {
              final idx = e.key;
              final acc = e.value;
              final isActive = idx == _activeIndex;
              return GestureDetector(
                onTap: () => _switchAccount(idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppTheme.primaryBlue : const Color(0xFFDDE3EE),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Radio indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? AppTheme.primaryBlue : Colors.transparent,
                          border: Border.all(
                            color: isActive ? AppTheme.primaryBlue : const Color(0xFFDDE3EE),
                            width: 2,
                          ),
                        ),
                        child: isActive
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(acc.isBank ? Icons.account_balance : Icons.qr_code_scanner,
                            color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(acc.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                            const SizedBox(height: 3),
                            Text(acc.subtitle,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            if (!acc.verified) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3CD),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('⏳ Pending Verification',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                              ),
                            ],
                            if (acc.verified && isActive) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Default',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _showAddAccountSheet,
                icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
                label: const Text('Add New Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Account Bottom Sheet ──────────────────────────────────────────────────

class _AddAccountSheet extends StatefulWidget {
  final void Function(_Account account) onSaved;
  final void Function(String, Color) onToast;
  const _AddAccountSheet({required this.onSaved, required this.onToast});
  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  int _tabIdx = 0; // 0=Bank, 1=UPI
  bool _loading = false;
  bool _obscureAccNum = true;
  String _accountType = 'Savings';
  String _selectedBank = 'SBI';

  final _nameCtrl = TextEditingController(text: 'Syed Rayan Hussaini');
  final _accNumCtrl = TextEditingController();
  final _confirmAccCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();

  // ── Error strings (null = no error) ──────────────────────────────────────
  String? _nameErr, _accNumErr, _confirmErr, _ifscErr, _upiErr;

  static final _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  static final _upiRegex  = RegExp(r'^[a-zA-Z0-9._\-]+@[a-zA-Z]{3,}$');
  static final _lettersOnlyRegex = RegExp(r"^[a-zA-Z ]+$");

  @override
  void initState() {
    super.initState();
    // Clear errors on typing
    _nameCtrl.addListener(() { if (_nameErr != null) setState(() => _nameErr = null); });
    _accNumCtrl.addListener(() { if (_accNumErr != null) setState(() => _accNumErr = null); });
    _confirmAccCtrl.addListener(() { if (_confirmErr != null) setState(() => _confirmErr = null); });
    _ifscCtrl.addListener(() { if (_ifscErr != null) setState(() => _ifscErr = null); });
    _upiCtrl.addListener(() { if (_upiErr != null) setState(() => _upiErr = null); });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _accNumCtrl.dispose(); _confirmAccCtrl.dispose();
    _ifscCtrl.dispose(); _upiCtrl.dispose();
    super.dispose();
  }

  void _pickBank() {
    final banks = ['SBI', 'HDFC', 'ICICI', 'Axis', 'Kotak', 'Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 48, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text('Select Bank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
            const SizedBox(height: 16),
            ...banks.map((b) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(b, style: TextStyle(fontSize: 16, fontWeight: b == _selectedBank ? FontWeight.w700 : FontWeight.w500,
                  color: b == _selectedBank ? AppTheme.primaryBlue : const Color(0xFF0A1F44))),
              trailing: b == _selectedBank ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue) : null,
              onTap: () { setState(() => _selectedBank = b); Navigator.pop(context); },
            )),
          ],
        ),
      ),
    );
  }

  void _saveAndVerify() async {
    // ── Full validation
    bool valid = true;
    String? nameErr, accErr, confirmErr, ifscErr, upiErr;

    if (_tabIdx == 0) {
      final name = _nameCtrl.text.trim();
      if (name.length < 3 || !_lettersOnlyRegex.hasMatch(name)) {
        nameErr = 'Please enter a valid name'; valid = false;
      }
      if (_selectedBank.isEmpty) {
        valid = false;
      }
      final accNum = _accNumCtrl.text.trim();
      if (accNum.length < 9 || accNum.length > 18) {
        accErr = 'Enter a valid account number (9–18 digits)'; valid = false;
      }
      if (_confirmAccCtrl.text.trim() != accNum) {
        confirmErr = 'Account numbers do not match'; valid = false;
      }
      final ifsc = _ifscCtrl.text.trim().toUpperCase();
      if (!_ifscRegex.hasMatch(ifsc)) {
        ifscErr = 'Enter a valid IFSC code (e.g. SBIN0001234)'; valid = false;
      }
      if (_accountType.isEmpty) {
        valid = false;
      }
    } else {
      final upi = _upiCtrl.text.trim();
      if (!_upiRegex.hasMatch(upi)) {
        upiErr = 'Enter a valid UPI ID (e.g. name@upi)'; valid = false;
      }
    }

    setState(() {
      _nameErr = nameErr; _accNumErr = accErr;
      _confirmErr = confirmErr; _ifscErr = ifscErr;
      _upiErr = upiErr;
    });

    if (!valid) return;

    // ── All valid — proceed
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    final acc = _tabIdx == 0
        ? _Account(title: _selectedBank, subtitle: '•••• ${_accNumCtrl.text.length > 4 ? _accNumCtrl.text.substring(_accNumCtrl.text.length - 4) : "••••"}', isBank: true, verified: false)
        : _Account(title: 'UPI', subtitle: _upiCtrl.text.trim(), isBank: false, verified: false);
    widget.onSaved(acc);
    widget.onToast('Account Added Successfully ✓', const Color(0xFF34C759));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(child: Container(width: 48, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add New Account',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
                  const SizedBox(height: 20),
                  // Tab pills
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['Bank Account', 'UPI ID'].asMap().entries.map((e) {
                        final sel = e.key == _tabIdx;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabIdx = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 38,
                              decoration: BoxDecoration(
                                color: sel ? AppTheme.primaryBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(e.value,
                                    style: TextStyle(color: sel ? Colors.white : AppTheme.textSecondary,
                                        fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _tabIdx == 0 ? _buildBankForm() : _buildUpiForm(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveAndVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save & Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankForm() {
    return Column(
      key: const ValueKey('bank'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(label: 'Account Holder Name', ctrl: _nameCtrl),
        const SizedBox(height: 14),
        // Bank Name tap
        _label('Bank Name'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickBank,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDE3EE)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(_selectedBank,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44)))),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Account Number with show/hide
        _label('Account Number'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE3EE)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _accNumCtrl,
                  obscureText: _obscureAccNum,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(_obscureAccNum ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _obscureAccNum = !_obscureAccNum),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _field(label: 'Confirm Account Number', ctrl: _confirmAccCtrl, isNumeric: true),
        const SizedBox(height: 14),
        _label('IFSC Code'),
        const SizedBox(height: 6),
        TextField(
          controller: _ifscCtrl,
          maxLength: 11,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            hintText: 'e.g. HDFC0001234',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _label('Account Type'),
        const SizedBox(height: 8),
        Row(
          children: ['Savings', 'Current'].map((t) {
            final sel = t == _accountType;
            return GestureDetector(
              onTap: () => setState(() => _accountType = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: sel ? AppTheme.primaryBlue : const Color(0xFFDDE3EE), width: 1.5),
                ),
                child: Text(t,
                    style: TextStyle(color: sel ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUpiForm() {
    return Column(
      key: const ValueKey('upi'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('UPI ID'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
        color: _upiErr != null ? AppTheme.criticalRed : (_upiCtrl.text.isEmpty ? const Color(0xFFDDE3EE) : (_upiRegex.hasMatch(_upiCtrl.text.trim()) ? const Color(0xFF34C759) : const Color(0xFFDDE3EE))),
              width: _upiErr != null ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFFDDE3EE))),
                ),
                child: const Text('@', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
              ),
              Expanded(
                child: TextField(
                  controller: _upiCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(14), hintText: 'yourname@upi'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (_upiCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    _upiRegex.hasMatch(_upiCtrl.text.trim()) ? Icons.check_circle : Icons.cancel,
                    color: _upiRegex.hasMatch(_upiCtrl.text.trim()) ? const Color(0xFF34C759) : AppTheme.criticalRed,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
        if (_upiErr != null) ...[
          const SizedBox(height: 6),
          Text(_upiErr!, style: const TextStyle(fontSize: 12, color: AppTheme.criticalRed)),
        ] else if (_upiCtrl.text.isNotEmpty && !_upiRegex.hasMatch(_upiCtrl.text.trim())) ...[
          const SizedBox(height: 6),
          const Text('Enter a valid UPI ID (e.g. name@upi)', style: TextStyle(fontSize: 12, color: AppTheme.criticalRed)),
        ],
        const SizedBox(height: 20),
        _label('Linked Mobile'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE3EE)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(6)),
                child: const Text('+91', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              const Text('9876543210', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
              const Spacer(),
              const Icon(Icons.lock_outline, color: Color(0xFFC7C7CC), size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String t) =>
      Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary));

  Widget _field({required String label, required TextEditingController ctrl, bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE3EE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Toast Banner Overlay ──────────────────────────────────────────────────────

class _ToastBanner extends StatefulWidget {
  final String message;
  final Color color;
  final VoidCallback onRemove;
  const _ToastBanner({required this.message, required this.color, required this.onRemove});
  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onRemove());
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 32, right: 32,
      child: SlideTransition(
        position: _slide,
        child: Material(
          borderRadius: BorderRadius.circular(50),
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(50)),
            child: Text(widget.message, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ),
    );
  }
}
