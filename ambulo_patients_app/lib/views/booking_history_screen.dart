import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../viewmodels/booking_provider.dart';
import 'location_selection_screen.dart';
import 'main_layout.dart';
import 'nurse_assigned_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

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
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
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

                // ── UPCOMING section ──
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

                // ── RECENT section ──
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
                _buildRideCard(
                  context,
                  'ALS Ambulance',
                  Icons.favorite_border,
                  'Today · 10:15 AM',
                  '₹999',
                  'Your Location',
                  'Apollo Hospital, Jubilee Hills',
                ),
                const SizedBox(height: 12),
                _buildRideCard(
                  context,
                  'BLS Ambulance',
                  Icons.medical_services_outlined,
                  'Mar 15 · 9:30 AM',
                  '₹499',
                  'Banjara Hills',
                  'KIMS Hospital',
                ),
                const SizedBox(height: 12),
                _buildRideCard(
                  context,
                  'Ambu Bike',
                  Icons.pedal_bike,
                  'Mar 10 · 8:40 AM',
                  '₹199',
                  'Hitec City',
                  'Yashoda Hospital',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
    String dropoff,
  ) {
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
                          ambulanceType: title.contains('ALS') ? 'ALS' : title.contains('Bike') ? 'Bike' : 'BLS',
                          initialTab: LocTab.pickup,
                          prefilledDrop: dropoff,
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
