import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/earnings_activity_screen.dart';
import 'package:ambulao_driver/screens/wallet_screen.dart';

// ── Period Data Models ─────────────────────────────────────────────────────────

class _PeriodData {
  final String label;
  final String earnings;
  final int earningsInt;   // raw int for comparison
  final int? prevEarnings; // null = no comparison (All Time)
  final String trips;
  final String hours;
  final String acceptance;
  final String rating;
  final List<_BarEntry> chartBars;
  final List<Map<String, dynamic>> tripList;

  const _PeriodData({
    required this.label,
    required this.earnings,
    required this.earningsInt,
    this.prevEarnings,
    required this.trips,
    required this.hours,
    required this.acceptance,
    required this.rating,
    required this.chartBars,
    required this.tripList,
  });
}

class _BarEntry {
  final String label;
  final int amount;
  const _BarEntry(this.label, this.amount);
}

final _periodData = [
  _PeriodData(
    label: 'This Week',
    earnings: '₹2,840',
    earningsInt: 2840,
    prevEarnings: 4120,
    trips: '18',
    hours: '24.5h',
    acceptance: '94%',
    rating: '4.92',
    chartBars: const [
      _BarEntry('Mon', 320), _BarEntry('Tue', 580), _BarEntry('Wed', 240),
      _BarEntry('Thu', 410), _BarEntry('Fri', 620), _BarEntry('Sat', 490), _BarEntry('Sun', 180),
    ],
    tripList: [
      {'time': 'Today 8:30 AM', 'dist': '3.2 km', 'amt': '₹280', 'type': 'Emergency'},
      {'time': 'Today 11:00 AM', 'dist': '5.1 km', 'amt': '₹420', 'type': 'Transfer'},
      {'time': 'Yesterday 3:45 PM', 'dist': '2.8 km', 'amt': '₹240', 'type': 'Emergency'},
    ],
  ),
  _PeriodData(
    label: 'Last Week',
    earnings: '₹4,120',
    earningsInt: 4120,
    prevEarnings: 3560,
    trips: '31',
    hours: '38.0h',
    acceptance: '91%',
    rating: '4.88',
    chartBars: const [
      _BarEntry('Mon', 720), _BarEntry('Tue', 480), _BarEntry('Wed', 890),
      _BarEntry('Thu', 350), _BarEntry('Fri', 760), _BarEntry('Sat', 640), _BarEntry('Sun', 280),
    ],
    tripList: [
      {'time': 'Mar 4, 9:00 AM', 'dist': '6.4 km', 'amt': '₹520', 'type': 'Emergency'},
      {'time': 'Mar 4, 2:15 PM', 'dist': '4.0 km', 'amt': '₹340', 'type': 'Transfer'},
      {'time': 'Mar 3, 8:50 PM', 'dist': '7.2 km', 'amt': '₹610', 'type': 'Emergency'},
    ],
  ),
  _PeriodData(
    label: 'This Month',
    earnings: '₹11,360',
    earningsInt: 11360,
    prevEarnings: 9840,
    trips: '87',
    hours: '112.0h',
    acceptance: '93%',
    rating: '4.90',
    chartBars: const [
      _BarEntry('Wk 1', 2840), _BarEntry('Wk 2', 3100), _BarEntry('Wk 3', 2890), _BarEntry('Wk 4', 2530),
    ],
    tripList: [
      {'time': 'Mar 10, 10:00 AM', 'dist': '5.5 km', 'amt': '₹460', 'type': 'Transfer'},
      {'time': 'Mar 9, 7:20 PM', 'dist': '3.8 km', 'amt': '₹320', 'type': 'Emergency'},
      {'time': 'Mar 8, 11:45 AM', 'dist': '9.1 km', 'amt': '₹780', 'type': 'Emergency'},
    ],
  ),
  _PeriodData(
    label: 'All Time',
    earnings: '₹68,450',
    earningsInt: 68450,
    prevEarnings: null, // no comparison for All Time
    trips: '542',
    hours: '710.0h',
    acceptance: '92%',
    rating: '4.92',
    chartBars: const [
      _BarEntry('Jan', 4200), _BarEntry('Feb', 5800), _BarEntry('Mar', 3500),
      _BarEntry('Apr', 6900), _BarEntry('May', 7200), _BarEntry('Jun', 5100),
      _BarEntry('Jul', 6400), _BarEntry('Aug', 7800), _BarEntry('Sep', 5900),
      _BarEntry('Oct', 6700), _BarEntry('Nov', 5500), _BarEntry('Dec', 3450),
    ],
    tripList: [
      {'time': 'Feb 28, 3:30 PM', 'dist': '11.2 km', 'amt': '₹950', 'type': 'Emergency'},
      {'time': 'Feb 14, 9:00 AM', 'dist': '8.5 km', 'amt': '₹720', 'type': 'Transfer'},
      {'time': 'Jan 30, 6:00 PM', 'dist': '4.2 km', 'amt': '₹360', 'type': 'Emergency'},
    ],
  ),
];

// ── EarningsScreen ────────────────────────────────────────────────────────────

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  int _selectedTab = 0;
  String? _selectedBar;

  _PeriodData get _current => _periodData[_selectedTab];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Earnings',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const EarningsActivityScreen())),
                    child: const Text('Activity',
                        style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // Tab pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['This Week', 'Last Week', 'This Month', 'All Time']
                      .asMap().entries.map((e) {
                    final sel = e.key == _selectedTab;
                    return GestureDetector(
                      onTap: () => setState(() { _selectedTab = e.key; _selectedBar = null; }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: sel ? AppTheme.primaryBlue : const Color(0xFFDDE3EE), width: 1.5),
                        ),
                        child: Text(e.value,
                            style: TextStyle(
                              color: sel ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF0F4FF)),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: _buildContent(key: ValueKey(_selectedTab)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({Key? key}) {
    final d = _current;
    final maxAmt = d.chartBars.map((b) => b.amount).reduce((a, b) => a > b ? a : b).toDouble();

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total earnings
          Text('Total Earnings', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text(d.earnings,
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFF0A1F44))),
          const SizedBox(height: 8),
          // Performance comparison arrow chip (Fix 1)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: _buildComparisonChip(d, key: ValueKey('chip_$_selectedTab')),
          ),
          const SizedBox(height: 24),

          // Metric stat tiles — each tappable
          Row(children: [
            Expanded(child: _TappableStatCard(
              icon: Icons.access_time, label: 'Online Time', value: d.hours,
              onTap: () => _showHoursSheet(context, d),
            )),
            const SizedBox(width: 12),
            Expanded(child: _TappableStatCard(
              icon: Icons.route, label: 'Trips', value: d.trips,
              onTap: () => _showTripsSheet(context, d),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _TappableStatCard(
              icon: Icons.star_border, label: 'Rating', value: d.rating,
              onTap: () => _showRatingSheet(context),
            )),
            const SizedBox(width: 12),
            Expanded(child: _TappableStatCard(
              icon: Icons.trending_up, label: 'Acceptance', value: d.acceptance,
              onTap: () => _showAcceptanceSheet(context, d),
            )),
          ]),
          const SizedBox(height: 28),

          // Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
              Text(d.chartBars.length == 7 ? 'Mon–Sun' : d.chartBars.length == 4 ? 'By Week' : 'Jan–Dec',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: d.chartBars.map((b) {
                final height = (b.amount / maxAmt) * 110.0;
                final isSel = _selectedBar == b.label;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBar = isSel ? null : b.label),
                  child: SizedBox(
                    width: d.chartBars.length <= 4 ? 60 : d.chartBars.length <= 7 ? 36 : 22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isSel)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(b.amount >= 1000 ? '₹${b.amount ~/ 1000}k' : '₹${b.amount}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: height.clamp(8, 110),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryBlue : const Color(0xFFE8F2FF),
                            borderRadius: BorderRadius.circular(6),
                            border: isSel ? null : Border.all(color: AppTheme.primaryBlue, width: 1),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(b.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSel ? AppTheme.primaryBlue : AppTheme.textSecondary,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Wallet shortcut
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Wallet Balance', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('₹1,250', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppTheme.primaryBlue, width: 1.5)),
                  child: const Text('Withdraw', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ]),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Recent Trips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
          const SizedBox(height: 12),
          ...d.tripList.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F4FF)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.route, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['time'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                const SizedBox(height: 3),
                Row(children: [
                  Text(t['dist'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(4)),
                    child: Text(t['type'] as String, style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ])),
              Text(t['amt'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
            ]),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 52,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EarningsActivityScreen())),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF0F4FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('See Full History', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Fix 1: Performance comparison chip ────────────────────────────────────
  Widget _buildComparisonChip(_PeriodData d, {Key? key}) {
    final prev = d.prevEarnings;
    if (prev == null) return const SizedBox.shrink(key: ValueKey('none'));
    final curr = d.earningsInt;
    final diff = curr - prev;
    final isUp = diff >= 0;
    final pct = ((diff.abs() / prev) * 100).toStringAsFixed(1);
    final sign = isUp ? '+' : '−';
    final absAmt = diff.abs() >= 1000
        ? '₹${(diff.abs() ~/ 1000)},${(diff.abs() % 1000).toString().padLeft(3, '0')}'
        : '₹${diff.abs()}';
    final compLabel = d.label == 'This Week'
        ? 'vs last week'
        : d.label == 'Last Week'
            ? 'vs previous week'
            : 'vs last month';
    final bgColor = isUp
        ? const Color(0x1F34C759) // green 12%
        : const Color(0x1AFF3B30); // red 10%
    final fgColor = isUp ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(50)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: fgColor),
        const SizedBox(width: 4),
        Text(
          '$absAmt $compLabel ($sign$pct%)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fgColor),
        ),
      ]),
    );
  }

  // ── Detail Sheets ─────────────────────────────────────────────────────────

  void _showHoursSheet(BuildContext ctx, _PeriodData d) {
    _showDetailSheet(ctx, title: 'Online Hours', icon: Icons.access_time, child: _HoursDetail(d: d));
  }

  void _showTripsSheet(BuildContext ctx, _PeriodData d) {
    _showDetailSheet(ctx, title: 'Trip History', icon: Icons.local_hospital, child: _TripsDetail(d: d));
  }

  void _showRatingSheet(BuildContext ctx) {
    _showDetailSheet(ctx, title: 'Your Rating', icon: Icons.star, child: const _RatingDetail());
  }

  void _showAcceptanceSheet(BuildContext ctx, _PeriodData d) {
    _showDetailSheet(ctx, title: 'Acceptance Rate', icon: Icons.check_circle, child: _AcceptanceDetail(d: d));
  }

  void _showDetailSheet(BuildContext ctx, {required String title, required IconData icon, required Widget child}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Center(child: Container(width: 48, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0040A0)))),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ]),
            ),
            Expanded(child: SingleChildScrollView(controller: sc, padding: const EdgeInsets.all(24), child: child)),
          ]),
        ),
      ),
    );
  }

}

// ── Detail Content Widgets ────────────────────────────────────────────────────

class _HoursDetail extends StatelessWidget {
  final _PeriodData d;
  const _HoursDetail({required this.d});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _detailStatRow('Total Hours', d.hours, 'Last Period', '32.0h'),
      const SizedBox(height: 20),
      const Text('Peak Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(16)),
        child: Row(children: const [
          Icon(Icons.wb_twilight, color: AppTheme.primaryBlue),
          SizedBox(width: 12),
          Text('Most active: 6PM – 9PM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0040A0))),
        ]),
      ),
      const SizedBox(height: 20),
      const Text('Daily Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 12),
      ...List.generate(7, (i) {
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final hrs = [3.5, 5.0, 2.5, 4.0, 6.5, 5.5, 1.0];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 36, child: Text(days[i], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: hrs[i] / 7,
                minHeight: 10,
                backgroundColor: const Color(0xFFE8F2FF),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
              ),
            )),
            const SizedBox(width: 8),
            Text('${hrs[i]}h', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
          ]),
        );
      }),
    ]);
  }
}

class _TripsDetail extends StatelessWidget {
  final _PeriodData d;
  const _TripsDetail({required this.d});

  @override
  Widget build(BuildContext context) {
    final total = int.tryParse(d.trips) ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _miniStatTile('Total', d.trips)),
        const SizedBox(width: 10),
        Expanded(child: _miniStatTile('Completed', '${total - 2}')),
        const SizedBox(width: 10),
        Expanded(child: _miniStatTile('Cancelled', '2')),
        const SizedBox(width: 10),
        Expanded(child: _miniStatTile('Active', '0')),
      ]),
      const SizedBox(height: 20),
      const Text('Trip Types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 12),
      _progressRow('Emergency', 0.65, '65%'),
      const SizedBox(height: 8),
      _progressRow('Hospital Transfer', 0.35, '35%'),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _detailStatTile('Avg Distance', '5.2 km')),
        const SizedBox(width: 12),
        Expanded(child: _detailStatTile('Avg Duration', '18 min')),
      ]),
      const SizedBox(height: 20),
      const Text('Recent Trips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 12),
      ...d.tripList.take(3).map((t) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.local_hospital, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t['time'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
            Text(t['dist'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          Text(t['amt'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
        ]),
      )),
    ]);
  }
}

class _RatingDetail extends StatelessWidget {
  const _RatingDetail();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Column(children: [
        const Text('4.92', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Color(0xFF0A1F44))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
            Icon(i < 4 ? Icons.star : Icons.star_half, color: Colors.amber, size: 28))),
        const SizedBox(height: 6),
        const Text('Based on 248 ratings', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 24),
      const Text('Star Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 12),
      ...[5,4,3,2,1].asMap().entries.map((e) {
        final vals = [0.72, 0.20, 0.05, 0.02, 0.01];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Text('${e.value}★', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
            const SizedBox(width: 10),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: vals[e.key], minHeight: 10,
                backgroundColor: const Color(0xFFE8F2FF),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
              ),
            )),
            const SizedBox(width: 8),
            Text('${(vals[e.key] * 100).toInt()}%',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        );
      }),
      const SizedBox(height: 20),
      const Text('Recent Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 12),
      ...[
        {'comment': 'Very professional and quick response!', 'stars': 5},
        {'comment': 'Smooth drive, arrived on time.', 'stars': 5},
        {'comment': 'Good experience overall.', 'stars': 4},
      ].map((r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: List.generate(r['stars'] as int, (_) => const Icon(Icons.star, color: Colors.amber, size: 16))),
          const SizedBox(height: 6),
          Text(r['comment'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF0A1F44))),
        ]),
      )),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(14)),
        child: const Row(children: [
          Icon(Icons.lightbulb_outline, color: AppTheme.primaryBlue),
          SizedBox(width: 12),
          Expanded(child: Text('Greet patients warmly and drive smoothly to keep your rating above 4.8.',
              style: TextStyle(fontSize: 13, color: Color(0xFF0040A0)))),
        ]),
      ),
    ]);
  }
}

class _AcceptanceDetail extends StatelessWidget {
  final _PeriodData d;
  const _AcceptanceDetail({required this.d});

  @override
  Widget build(BuildContext context) {
    final pct = int.tryParse(d.acceptance.replaceAll('%', '')) ?? 92;
    final accepted = ((pct / 100) * (int.tryParse(d.trips) ?? 0)).round();
    final declined = (int.tryParse(d.trips) ?? 0) - accepted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Column(children: [
        Text(d.acceptance, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Color(0xFF0040A0))),
        const Text('Acceptance Rate', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _detailStatTile('Accepted', '$accepted trips')),
        const SizedBox(width: 12),
        Expanded(child: _detailStatTile('Declined', '$declined trips')),
      ]),
      const SizedBox(height: 20),
      const Text('7-Day Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      const SizedBox(height: 12),
      SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [88, 91, 94, 89, 96, 93, pct].asMap().entries.map((e) {
            final days = ['Mo','Tu','We','Th','Fr','Sa','Su'];
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              SizedBox(
                width: 28,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: e.value * 0.6,
                  decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(5)),
                ),
              ),
              const SizedBox(height: 4),
              Text(days[e.key], style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ]);
          }).toList(),
        ),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(14)),
        child: const Row(children: [
          Icon(Icons.info_outline, color: AppTheme.primaryBlue),
          SizedBox(width: 12),
          Expanded(child: Text('Maintaining above 80% keeps you eligible for surge bonuses and priority dispatching.',
              style: TextStyle(fontSize: 13, color: Color(0xFF0040A0)))),
        ]),
      ),
    ]);
  }
}

// ── Shared Helper Widgets ─────────────────────────────────────────────────────

Widget _detailStatRow(String l1, String v1, String l2, String v2) {
  return Row(children: [
    Expanded(child: _detailStatTile(l1, v1)),
    const SizedBox(width: 12),
    Expanded(child: _detailStatTile(l2, v2)),
  ]);
}

Widget _detailStatTile(String label, String value) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
    ]),
  );
}

Widget _miniStatTile(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0A1F44))),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    ]),
  );
}

Widget _progressRow(String label, double value, String pct) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
      Text(pct, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
    ]),
    const SizedBox(height: 4),
    ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value, minHeight: 8,
        backgroundColor: const Color(0xFFE8F2FF),
        valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
      ),
    ),
  ]);
}

// ── Tappable Stat Card ────────────────────────────────────────────────────────

class _TappableStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappableStatCard({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 22),
            const Icon(Icons.open_in_new, color: AppTheme.primaryBlue, size: 14),
          ]),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0A1F44))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}
