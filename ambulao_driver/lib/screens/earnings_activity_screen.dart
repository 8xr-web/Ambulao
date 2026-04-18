import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/services/trip_service.dart';

class EarningsActivityScreen extends StatefulWidget {
  const EarningsActivityScreen({super.key});

  @override
  State<EarningsActivityScreen> createState() =>
      _EarningsActivityScreenState();
}

class _EarningsActivityScreenState extends State<EarningsActivityScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('driver_uid') ?? '';

    final trips = await TripService.getTripHistory(driverId);
    if (mounted) {
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF0A1F44)),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF007AFF)),
            )
          : _trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🚑', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 16),
                      Text(
                        'No completed trips yet',
                        style: TextStyle(
                          color: Color(0xFF6E6E73),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    final fare = (trip['final_fare'] ??
                        trip['estimated_fare'] ?? 0.0) as num;
                    final pickup = (trip['pickup'] as Map<String,
                            dynamic>?)?['address'] as String? ??
                        'Unknown';
                    final drop = (trip['destination'] as Map<String,
                            dynamic>?)?['address'] as String? ??
                        'Unknown';
                    final ambulanceType =
                        trip['ambulance_type'] as String? ?? 'BLS';
                    final isEmergency =
                        ambulanceType == 'BLS' || ambulanceType == 'ALS';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE0E8FF), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                              isEmergency
                                  ? Icons.monitor_heart
                                  : Icons.local_shipping,
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
                                  '$ambulanceType Trip',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0A1F44),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'From: $pickup',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'To: $drop',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34C759)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF34C759),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${fare.toStringAsFixed(0)}',
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
