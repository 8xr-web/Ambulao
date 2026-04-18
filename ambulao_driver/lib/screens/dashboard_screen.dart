import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/widgets/bottom_sheet_card.dart';
import 'package:ambulao_driver/widgets/map_background_mock.dart';
import 'package:ambulao_driver/screens/incoming_request_screen.dart';
import 'package:ambulao_driver/screens/earnings_screen.dart';
import 'package:ambulao_driver/services/trip_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isOnline = false;
  Duration _onlineTime = Duration.zero;
  Timer? _timer;
  StreamSubscription<QuerySnapshot>? _tripSubscription;
  DateTime? _onlineStartTime;
  String _currentDriverId = '';
  String _driverAmbulanceType = 'BLS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['isOnline'] != null) {
        setState(() {
          isOnline = args['isOnline'] as bool;
        });
        if (isOnline) _startOnlineTimer();
      } else {
        _loadOnlineStatus();
      }
    });
  }

  Future<void> _loadOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOnline = prefs.getBool('driver_is_online') ?? false;
    });
    if (isOnline) _startOnlineTimer();
  }

  void _startOnlineTimer() {
    _onlineTime = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _onlineTime += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tripSubscription?.cancel();
    super.dispose();
  }

  Future<void> _goOnline() async {
    // Update UI immediately so the button feels responsive
    setState(() => isOnline = true);
    _startOnlineTimer();

    // Capture the exact moment the driver goes online.
    // Only trips created AFTER this timestamp will trigger the notification.
    _onlineStartTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    _currentDriverId = prefs.getString('driver_uid') ?? '';
    _driverAmbulanceType = prefs.getString('pref_ambulance_type') ?? 'BLS';
    await prefs.setBool('driver_is_online', true);

    // Update driver status in Firestore (non-blocking — UI already updated)
    if (_currentDriverId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(_currentDriverId)
            .set({
          'is_online': true,
          'status': 'online',
          'last_online_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore driver update failed: $e');
      }
    }

    // Start listening — only trips with ambulance_type match
    _tripSubscription = TripService.listenForPendingTrips(
      ambulanceType: _driverAmbulanceType,
    ).listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final tripData = change.doc.data() as Map<String, dynamic>;
          final tripId = change.doc.id;
          
          // 1. Client-side filtering: Ignore trips created before we went online
          final createdAt = tripData['created_at'] as Timestamp?;
          if (createdAt != null && _onlineStartTime != null) {
            if (createdAt.toDate().isBefore(_onlineStartTime!)) continue;
          }

          // 2. Skip if already declined by this driver
          final declinedBy =
              List<String>.from(tripData['declined_by'] as List? ?? []);
          if (declinedBy.contains(_currentDriverId)) continue;

          // 3. Skip if already has a driver assigned
          if (tripData['driver_id'] != null) continue;

          debugPrint('LIVE Trip received: $tripId');
          _showIncomingRequest(tripId, tripData);
          break; // show one request at a time
        }
      }
    }, onError: (error) {
      debugPrint('Firestore listen error: $error');
    });
  }

  Future<void> _goOffline() async {
    _tripSubscription?.cancel();
    _tripSubscription = null;
    _onlineStartTime = null;
    _timer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driver_is_online', false);

    if (_currentDriverId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(_currentDriverId)
            .set({
          'is_online': false,
          'status': 'offline',
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore offline update failed: $e');
      }
    }

    setState(() => isOnline = false);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _showIncomingRequest(String tripId, Map<String, dynamic> tripData) {
    if (!mounted) return;
    
    print("DEBUG: Navigating to Incoming Request Screen for trip: $tripId");

    // Cancel subscription so we don't stack multiple screens
    _tripSubscription?.cancel();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingRequestScreen(
          tripId: tripId,
          patientName: tripData['patient_name'] ?? 'Emergency Patient',
          ambulanceType: tripData['ambulance_type'] ?? 'BLS',
          pickupAddress: tripData['pickup']?['address'] ?? 'Toli Chowki, Hyderabad',
          pickupLat: (tripData['pickup']?['lat'] ?? 17.4399).toDouble(),
          pickupLng: (tripData['pickup']?['lng'] ?? 78.3813).toDouble(),
          dropAddress: tripData['destination']?['address'] ?? 'Apollo Hospital',
          dropLat: (tripData['destination']?['lat'] ?? 17.45).toDouble(),
          dropLng: (tripData['destination']?['lng'] ?? 78.39).toDouble(),
          estimatedFare: (tripData['estimated_fare'] ?? 450.0).toDouble(),
          patientPhone: tripData['patient_phone'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: MapBackgroundMock(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main content column
              Column(
                children: [
                  const Spacer(),
                  // Bottom sheet
                  BottomSheetCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isOnline) ...[
                          Text(
                            "You're Online",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A1F44),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Online for ${_formatDuration(_onlineTime)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF0A1F44),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'High demand',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(text: ' in your area'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _goOffline,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: AppTheme.criticalRed,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Go Offline',
                                  style: TextStyle(
                                    color: AppTheme.criticalRed,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            "You're Offline",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A1F44),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Go online to start receiving requests',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _goOnline,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue
                                        .withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Go Online',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Top floating earnings pill
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: const _ExpandableEarningsCard(),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableEarningsCard extends StatelessWidget {
  const _ExpandableEarningsCard();

  void _showEarningsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EarningsDetailSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEarningsSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 15),
                children: [
                  TextSpan(
                    text: "Today's Earnings  ",
                    style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '₹0.00',
                    style: TextStyle(
                      color: Color(0xFF0A1F44),
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EarningsDetailSheet extends StatelessWidget {
  const _EarningsDetailSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F8FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Center(
              child: Container(
                width: 48, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Earnings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                  const SizedBox(height: 20),

                  // 3 Stat tiles
                  Row(
                    children: [
                      _statTile('Total Earned', '₹0.00', Icons.account_balance_wallet_outlined),
                      const SizedBox(width: 10),
                      _statTile('Trips', '0', Icons.local_taxi_outlined),
                      const SizedBox(width: 10),
                      _statTile('Online', '0h 0m', Icons.access_time_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Breakdown card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Earnings Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                        const SizedBox(height: 16),
                        _breakdownRow('Base fare total', '₹0.00'),
                        _breakdownRow('Premium charges', '₹0.00'),
                        _breakdownRow('Platform fees', '- ₹0.00', isDeduction: true),
                        const Divider(height: 24, color: Color(0xFFF0F4FF)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Net earnings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
                            Text('₹0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0040A0))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cash vs Digital split
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.money, color: AppTheme.successGreen),
                              SizedBox(height: 8),
                              Text('Cash', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              Text('₹0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.credit_card_outlined, color: AppTheme.primaryBlue),
                              SizedBox(height: 8),
                              Text('Digital', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              Text('₹0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Trip list placeholder
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, color: AppTheme.textSecondary, size: 36),
                          SizedBox(height: 8),
                          Text('No trips yet today', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hourly bar chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hourly Earnings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _bar('9AM', 0), _bar('11AM', 0),
                            _bar('1PM', 0), _bar('3PM', 0), _bar('5PM', 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const EarningsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeOutQuart;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('See Full History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDeduction ? AppTheme.criticalRed : const Color(0xFF0A1F44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double heightVal) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: heightVal > 0 ? heightVal : 8,
          decoration: BoxDecoration(
            color: heightVal > 0 ? AppTheme.primaryBlue : const Color(0xFFE8EDFB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

