import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/bank_details_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Change to negative (e.g. -110) to see warning banner
  final int _balance = 1250;

  String get _balanceStr {
    final abs = _balance.abs();
    if (abs >= 1000) {
      return '${_balance < 0 ? '-' : ''}₹${abs ~/ 1000},${(abs % 1000).toString().padLeft(3, '0')}';
    }
    return '${_balance < 0 ? '-' : ''}₹$abs';
  }

  Color get _balanceColor {
    if (_balance > 0) return const Color(0xFF34C759);
    if (_balance == 0) return const Color(0xFF0040A0);
    return const Color(0xFFFF3B30);
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
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: Color(0xFF0A1F44),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _balance < 0
                        ? const Color(0xFFFF9500).withValues(alpha: 0.6)
                        : AppTheme.primaryBlue.withValues(alpha: 0.3),
                    width: _balance < 0 ? 2 : 1.5,
                  ),
                  boxShadow: _balance < 0
                      ? [BoxShadow(color: const Color(0xFFFF9500).withValues(alpha: 0.18), blurRadius: 16, spreadRadius: 2)]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _balanceStr,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: _balanceColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _balance < 0 ? const Color(0xFFFFEEEA) : const Color(0xFFE8F2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: _balance < 0 ? const Color(0xFFFF3B30) : AppTheme.primaryBlue,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment reminder — only shown when balance is negative
              if (_balance < 0) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: Color(0xFFFF9500), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Reminder',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF9500)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Balance is $_balanceStr. You'll lose access to cash trips on 13 Mar.",
                              style: const TextStyle(fontSize: 13, color: Color(0xFF8B6914)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment flow coming soon'), behavior: SnackBarBehavior.floating)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9500), foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                    child: const Text('Make Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Withdraw button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showWithdrawSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Withdraw Funds',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Payout activity
              const Text(
                'Payout Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1F44),
                ),
              ),
              const SizedBox(height: 12),
              ...[
                {'label': 'Trip payout', 'amount': '+₹112', 'date': 'Today'},
                {'label': 'Trip payout', 'amount': '+₹85', 'date': 'Today'},
                {
                  'label': 'Account deduction',
                  'amount': '-₹50',
                  'date': 'Yesterday'
                },
              ].map(
                (t) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['label']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A1F44),
                            ),
                          ),
                          Text(
                            t['date']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        t['amount']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: t['amount']!.startsWith('+')
                              ? AppTheme.successGreen
                              : AppTheme.criticalRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    const double availableBalance = 1250.0;
    String? errorMessage;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 48, height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Withdraw Funds', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                  const SizedBox(height: 24),
                  
                  // Amount field
                  const Text('Enter Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FBFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: errorMessage != null ? AppTheme.criticalRed : const Color(0xFFDDE3EE)),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        if (errorMessage != null) {
                          setSheetState(() => errorMessage = null);
                        }
                      },
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 20, right: 8),
                          child: Text('₹', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        hintText: '0',
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: AppTheme.criticalRed, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 6),
                  const Text('Available balance: ₹1,250.00', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  
                  // Bank Details Link
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BankDetailsScreen()));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDDE3EE), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.account_balance, color: AppTheme.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Bank / UPI Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                                  Text('HDFC Bank ending in 1234', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final val = double.tryParse(controller.text) ?? 0;
                        if (val < 100) {
                          setSheetState(() => errorMessage = 'Minimum withdrawal is ₹100');
                        } else if (val > availableBalance) {
                          setSheetState(() => errorMessage = 'Amount exceeds available balance');
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Withdrawal of ₹${controller.text} requested successfully!'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: const Text('Confirm Withdraw', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
