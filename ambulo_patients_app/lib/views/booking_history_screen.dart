import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../viewmodels/booking_provider.dart';
import 'location_selection_screen.dart';
import 'main_layout.dart';
import 'nurse_assigned_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('patient_uid') ?? '';
      if (uid.isEmpty) {
        setState(() { _isLoading = false; _trips = []; });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('trips')
          .where('patient_id', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();

      setState(() {
        _trips = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('BookingHistoryScreen: Firestore error — $e');
      setState(() { _isLoading = false; _trips = []; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final upcoming = bookingProvider.upcomingNurseBookings;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by location or date...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── UPCOMING nurse bookings ──
                if (upcoming.isNotEmpty) ...[
                  const Text(
                    'UPCOMING',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...upcoming.map((booking) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNurseBookingCard(context, booking, bookingProvider),
                  )),
                  const SizedBox(height: 8),
                ],

                // ── RECENT ambulance trips from Firestore ──
                const Text(
                  'RECENT',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    ),
                  )
                else if (_trips.isEmpty)
                  _buildEmptyState()
                else
                  ..._trips.map((trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRideCard(
                      context,
                      _ambulanceLabel(trip['ambulance_type'] ?? 'BLS'),
                      _ambulanceIcon(trip['ambulance_type'] ?? 'BLS'),
                      _formatDate(trip['created_at']),
                      '₹${(trip['estimated_fare'] ?? 0).toStringAsFixed(0)}',
                      trip['pickup']?['address'] ?? 'Pickup',
                      trip['destination']?['address'] ?? 'Destination',
                      rebookType: trip['ambulance_type'] ?? 'BLS',
                      rebookDrop: trip['destination']?['address'] ?? '',
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_hospital_outlined, color: AppColors.primaryBlue, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'No trips yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your completed trips will appear here.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _ambulanceLabel(String type) {
    switch (type) {
      case 'ALS': return 'ALS Ambulance';
      case 'Bike': return 'Ambu Bike';
      case 'LastRide': return 'Last Ride';
      default: return 'BLS Ambulance';
    }
  }

  IconData _ambulanceIcon(String type) {
    switch (type) {
      case 'ALS': return Icons.favorite_border;
      case 'Bike': return Icons.pedal_bike;
      case 'LastRide': return Icons.airport_shuttle_outlined;
      default: return Icons.medical_services_outlined;
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'Unknown date';
    if (ts is Timestamp) {
      final dt = ts.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Today · ${_timeStr(dt)}';
      if (diff.inDays == 1) return 'Yesterday · ${_timeStr(dt)}';
      return '${dt.day} ${_monthName(dt.month)} · ${_timeStr(dt)}';
    }
    return ts.toString();
  }

  String _timeStr(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String _monthName(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  Widget _buildNurseBookingCard(
    BuildContext context,
    NurseBooking booking,
    BookingProvider provider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1A6FE8), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6FE8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nurse — ${booking.serviceLabel}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Tomorrow · ${booking.startTime}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A99)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${booking.totalPrice}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Row(
                      children: [
                        Icon(Icons.check, color: AppColors.primaryBlue, size: 10),
                        SizedBox(width: 3),
                        Text(
                          'Confirmed',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Details sub-card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow('Nurse', '${booking.nurseName} · ⭐ 4.9'),
                  _detailRow('Duration', '${booking.durationHours} hrs (${booking.startTime} – ${booking.endTime})'),
                  _detailRow('Location', booking.location),
                  _detailRow('Booking ID', booking.bookingId, isSmall: true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      MainLayout.of(context)?.switchToHome();
                      MainLayout.homeNavKey.currentState?.push(
                        SmoothPageRoute(
                          page: NurseAssignedScreen(
                            serviceLabel: booking.serviceLabel,
                            durationHours: booking.durationHours,
                            nurseName: booking.nurseName,
                            totalPrice: booking.totalPrice,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => provider.removeNurseBooking(booking.bookingId),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Cancel Booking',
                      style: TextStyle(color: AppColors.primaryBlue, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF6B7A99),
              fontSize: isSmall ? 11 : 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isSmall ? const Color(0xFF9AA5BE) : AppColors.textPrimary,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(
    BuildContext context,
    String title,
    IconData icon,
    String date,
    String price,
    String pickup,
    String dropoff, {
    String rebookType = 'BLS',
    String rebookDrop = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Color(0xFF10B981), size: 10),
                        SizedBox(width: 3),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF065F46),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: AppColors.primaryBlue, size: 8),
                  Container(width: 1, height: 16, color: const Color(0xFFE5E7EB)),
                  const Icon(Icons.location_on, color: Color(0xFFFF3B30), size: 10),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dropoff,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showReceiptModal(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Receipt',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    MainLayout.of(context)?.switchToHome();
                    MainLayout.homeNavKey.currentState?.push(
                      SmoothPageRoute(
                        page: LocationSelectionScreen(
                          ambulanceType: rebookType,
                          initialTab: LocTab.pickup,
                          prefilledDrop: rebookDrop.isNotEmpty ? rebookDrop : dropoff,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: const Color(0xFFEEF4FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Rebook',
                    style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReceiptModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, color: AppColors.primaryBlue, size: 48),
            const SizedBox(height: 16),
            const Text('Receipt Downloaded', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Your invoice has been saved to device.', style: TextStyle(color: Color(0xFF6E6E73))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
