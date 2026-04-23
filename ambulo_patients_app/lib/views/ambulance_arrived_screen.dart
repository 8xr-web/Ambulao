import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trip_completed_screen.dart';

class AmbulanceArrivedScreen extends StatefulWidget {
  final String ambulanceType;
  final String pickupAddress;
  final String dropAddress;
  final double estimatedFare;
  final String paymentMethod;

  const AmbulanceArrivedScreen({
    super.key,
    required this.ambulanceType,
    required this.pickupAddress,
    required this.dropAddress,
    this.estimatedFare = 350.0,
    this.paymentMethod = 'cash',
  });

  @override
  State<AmbulanceArrivedScreen> createState() => _AmbulanceArrivedScreenState();
}

class _AmbulanceArrivedScreenState extends State<AmbulanceArrivedScreen> {
  static const LatLng _center = LatLng(17.4450, 78.3850);

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
      MaterialPageRoute(builder: (_) => TripCompletedScreen(
        tripId: '',
        driverName: 'Rajesh Kumar',
        ambulanceType: widget.ambulanceType,
        pickupAddress: widget.pickupAddress,
        dropAddress: widget.dropAddress,
        totalFare: widget.estimatedFare,
        paymentMethod: widget.paymentMethod,
      )),
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
            child: const GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 13.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),

          // ─── DRAGGABLE BOTTOM SHEET ──────────────────────────────────
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
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE1E7), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.where_to_vote_outlined, color: Color(0xFF065F46), size: 18),
                                    SizedBox(width: 8),
                                    Text('Ambulance Arrived', style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Driver card
                            _buildDriverCard(),
                            const SizedBox(height: 12),

                            // Address info
                            _buildAddressCard(),
                            const SizedBox(height: 12),

                            // Estimated fare
                            _buildFareCard(),
                            const SizedBox(height: 20),

                            // CTA button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _goToPayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A6FE8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Proceed to Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFF1A6FE8), borderRadius: BorderRadius.circular(13)),
            child: const Center(child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A0F1E))),
                SizedBox(height: 3),
                Text('BLS Paramedic · TS 09 AB 1234', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callNumber('+919999999999'),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.phone, color: Color(0xFF1A6FE8), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.circle, color: Color(0xFF1A6FE8), size: 10),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.pickupAddress, style: const TextStyle(color: Color(0xFF0A0F1E), fontSize: 13, fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on, color: Color(0xFF12B76A), size: 14),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.dropAddress, style: const TextStyle(color: Color(0xFF0A0F1E), fontSize: 13, fontWeight: FontWeight.w500))),
          ]),
        ],
      ),
    );
  }

  Widget _buildFareCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Estimated Fare', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 13)),
          Text('₹${widget.estimatedFare.toInt()}', style: const TextStyle(color: Color(0xFF1A6FE8), fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
