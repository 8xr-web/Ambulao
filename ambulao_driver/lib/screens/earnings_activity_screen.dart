import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class EarningsActivityScreen extends StatelessWidget {
  const EarningsActivityScreen({super.key});

  final List<Map<String, dynamic>> _trips = const [
    {
      'type': 'Emergency',
      'amount': '₹112',
      'detail': '8.4 km · 22 min',
      'status': 'Recalculated',
      'statusColor': 0xFF007AFF,
      'time': '09:45 AM',
    },
    {
      'type': 'Transfer',
      'amount': '₹85',
      'detail': '5.2 km · 14 min',
      'status': 'Cash collected',
      'statusColor': 0xFF34C759,
      'time': '11:22 AM',
    },
    {
      'type': 'Emergency',
      'amount': '₹138',
      'detail': '11.0 km · 30 min',
      'status': 'Cash collected',
      'statusColor': 0xFF34C759,
      'time': '01:10 PM',
    },
    {
      'type': 'Transfer',
      'amount': '₹67',
      'detail': '4.1 km · 09 min',
      'status': 'Cash collected',
      'statusColor': 0xFF34C759,
      'time': '03:30 PM',
    },
    {
      'type': 'Emergency',
      'amount': '₹95',
      'detail': '6.8 km · 18 min',
      'status': 'Cancelled',
      'statusColor': 0xFFFF3B30,
      'time': '05:00 PM',
    },
    {
      'type': 'Emergency',
      'amount': '₹158',
      'detail': '12.3 km · 35 min',
      'status': 'Cash collected',
      'statusColor': 0xFF34C759,
      'time': '07:15 PM',
    },
  ];

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
          'Activity',
          style: TextStyle(
            color: Color(0xFF0A1F44),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _trips.length,
        separatorBuilder: (context, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final trip = _trips[i];
          final isEmergency = trip['type'] == 'Emergency';
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isEmergency
                        ? const Color(0xFFFFEEEA)
                        : const Color(0xFFE8F2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEmergency ? Icons.monitor_heart : Icons.local_shipping,
                    color: isEmergency
                        ? AppTheme.criticalRed
                        : AppTheme.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['type']} Trip',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A1F44),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trip['detail']} · ${trip['time']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Color(trip['statusColor'] as int)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          trip['status'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(trip['statusColor'] as int),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  trip['amount'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A1F44),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
