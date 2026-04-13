import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_args.dart';
import 'trip_completed_screen.dart';

class AmbulanceArrivedScreen extends StatefulWidget {
  final BookingArgs args;
  const AmbulanceArrivedScreen({super.key, required this.args});

  @override
  State<AmbulanceArrivedScreen> createState() => _AmbulanceArrivedScreenState();
}

class _AmbulanceArrivedScreenState extends State<AmbulanceArrivedScreen> {
  // Kondapur (start/ambulance) to Apollo Hospital Jubilee Hills (end)
  final LatLng ambulancePos = const LatLng(17.4666, 78.3562);  // Kondapur
  final LatLng hospitalPos  = const LatLng(17.4239, 78.4116);  // Apollo Jubilee Hills
  final LatLng centerPos    = const LatLng(17.4450, 78.3850);

  Future<void> _callNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showToast("Unable to open phone dialer", isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF12B76A),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToPayment() {
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (_) => TripCompletedScreen(args: widget.args)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.44;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── MAP (top 44%) ────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: mapHeight,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: centerPos,
                initialZoom: 13.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ambulao.patient',
                ),
                // Dashed polyline — simulate with thin blue line
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [ambulancePos, const LatLng(17.4500, 78.3780), hospitalPos],
                      color: const Color(0xFF1A6FE8),
                      strokeWidth: 3.5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Ambulance Marker (blue circle with ambulance icon)
                    Marker(
                      point: ambulancePos,
                      width: 52, height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1A6FE8), width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: Center(
                          child: Container(
                            width: 30, height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A6FE8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emergency_outlined, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                    // User/origin blue dot
                    Marker(
                      point: const LatLng(17.4560, 78.3490),
                      width: 16, height: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A6FE8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ),
                    // Hospital Marker (green circle)
                    Marker(
                      point: hospitalPos,
                      width: 52, height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF12B76A), width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: Center(
                          child: Container(
                            width: 30, height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF12B76A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ─── DRAGGABLE BOTTOM SHEET (Fix 6) ──────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.58,
            minChildSize: 0.38,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.38, 0.58, 0.85],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, -6))],
                ),
                child: Column(
                  children: [
                    // Drag handle (Fix 6)
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE1E7), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // ── A. Driver / Journey Card (Fix 5 & 7) ──
                            _buildDriverCard(),
                            const SizedBox(height: 12),

                            // ── B. Hospital Destination Card ──
                            _buildHospitalCard(),
                            const SizedBox(height: 12),

                            // ── C. Metrics Row ──
                            _buildMetricsRow(),
                            const SizedBox(height: 12),

                            // ── D. Tracking Notification ──
                            _buildTrackingRow(),
                            const SizedBox(height: 12),

                            // ── E. Share Button ──
                            _buildShareButton(),
                            const SizedBox(height: 12),

                            // ── [TEMP TEST] Direct to Payment ──
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _goToPayment,
                                icon: const Icon(Icons.local_hospital_outlined, size: 18),
                                label: const Text('Arrived at Hospital → Payment',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEA580C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Driver + Journey Card (Fix 5, 7) ───────────────────────────────────────
  Widget _buildDriverCard() {
    String typeLabel = 'BLS';
    Color badgeColor = const Color(0xFF1A6FE8);
    if (widget.args.ambulanceType == 'ALS') { typeLabel = 'ALS'; badgeColor = const Color(0xFF003366); }
    else if (widget.args.ambulanceType == 'Bike') { typeLabel = 'Ambu Bike'; badgeColor = const Color(0xFF10B981); }
    else if (widget.args.ambulanceType == 'LastRide') { typeLabel = 'Last Ride'; badgeColor = const Color(0xFF6B7280); }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E4FF), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: const Color(0xFF1A6FE8), borderRadius: BorderRadius.circular(13)),
                child: const Center(child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A0F1E))),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text('$typeLabel Paramedic · ', style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
                        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                        const Text(' 4.9', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('TG 09 AB 1234 · ${widget.args.ambulanceType == 'Bike' ? 'Honda Activa' : 'Mahindra Bolero'}',
                        style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _callNumber('+918309249445'),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.phone, color: Color(0xFF1A6FE8), size: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(100)),
                    child: const Text('En Route', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0F2F5), height: 1),
          const SizedBox(height: 12),

          // Journey progress row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kondapur', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
              Text('Apollo Hospital', style: TextStyle(color: Color(0xFF1A6FE8), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.34,
                  child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFF1A6FE8), borderRadius: BorderRadius.circular(4))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1.1 km covered', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
              Text('2.1 km remaining', style: TextStyle(color: Color(0xFF1A6FE8), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Hospital Destination Card ─────────────────────────────────────────────
  Widget _buildHospitalCard() {
    return GestureDetector(
      onTap: _goToPayment,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A6FE8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apollo Hospital',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A0F1E))),
                  SizedBox(height: 2),
                  Text('Jubilee Hills, Hyderabad',
                      style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
                ],
              ),
            ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('~', style: TextStyle(color: Color(0xFF1A6FE8), fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('6', style: TextStyle(color: Color(0xFF1A6FE8), fontSize: 28, fontWeight: FontWeight.w900, height: 1.1)),
                    ],
                  ),
                  Text('min away', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Info Cards Row ────────────────────────────────────────────────────────
  Widget _buildMetricsRow() {
    return Row(
      children: [
        // Distance card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total distance', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                SizedBox(height: 6),
                Text('3.2 km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A0F1E))),
                SizedBox(height: 2),
                Text('Est. ₹499 fare', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Emergency contact card
        Expanded(
          child: GestureDetector(
            onTap: () => _showToast('Calling Priya...'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency contact', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                  SizedBox(height: 6),
                  Text('Priya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A0F1E))),
                  SizedBox(height: 2),
                  Text('+91 98765 43210', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tracking Notification ─────────────────────────────────────────────────
  Widget _buildTrackingRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: Color(0xFF12B76A), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          const Text(
            'Priya & Ravi are tracking your journey live',
            style: TextStyle(color: Color(0xFF065F46), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Share Live Location Button ─────────────────────────────────────────────
  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showToast('Live location shared!'),
        icon: const Icon(Icons.share_outlined, size: 18),
        label: const Text('Share live location',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A6FE8),
          side: const BorderSide(color: Color(0xFFD6E4FF), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
