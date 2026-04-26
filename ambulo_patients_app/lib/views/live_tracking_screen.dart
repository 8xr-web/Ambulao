import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import 'trip_completed_screen.dart';
import 'home_screen.dart';
import 'booking_history_screen.dart';
import 'panic_mode_screen.dart';
import 'profile_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String tripId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String ambulanceType;
  final String dropAddress;
  final double estimatedFare;
  final double pickupLat;
  final double pickupLng;

  const LiveTrackingScreen({
    super.key,
    required this.tripId,
    this.driverId = '',
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.ambulanceType,
    required this.dropAddress,
    required this.estimatedFare,
    this.pickupLat = 17.4399,
    this.pickupLng = 78.3813,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  StreamSubscription<DocumentSnapshot>? _tripSubscription;
  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  GoogleMapController? _mapController;
  LatLng? _driverLatLng;
  late LatLng _pickupLatLng;
  LatLng? _hospitalLatLng;   // destination / drop-off
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _pickupLatLng = LatLng(widget.pickupLat, widget.pickupLng);
    _listenForCompletion();
    if (widget.driverId.isNotEmpty) _listenForDriverLocation();
  }

  void _listenForDriverLocation() {
    _locationSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .doc(widget.driverId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final d = snap.data()!;
      // Driver app writes: drivers/{id} → { location: { lat: x, lng: y } }
      final location = d['location'] as Map<String, dynamic>?;
      if (location == null) return;
      final lat = (location['lat'] as num?)?.toDouble();
      final lng = (location['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return;
      if (lat == 0.0 && lng == 0.0) return;

      final newPos = LatLng(lat, lng);
      // Use hospital/destination as the polyline endpoint if available,
      // otherwise fall back to the pickup point.
      final destPos = _hospitalLatLng ?? _pickupLatLng;

      setState(() {
        _driverLatLng = newPos;
        _markers = {
          Marker(
            markerId: const MarkerId('driver'),
            position: newPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: widget.driverName, snippet: 'En route to hospital'),
          ),
          Marker(
            markerId: const MarkerId('hospital'),
            position: destPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
                title: 'Hospital',
                snippet: widget.dropAddress.isNotEmpty ? widget.dropAddress : 'Destination'),
          ),
        };
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [newPos, destPos],
            color: const Color(0xFF1A6FE8),
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        };
      });

      // Fit driver and hospital/destination in view
      _fitBounds(newPos, destPos);
    }, onError: (e) => debugPrint('LiveTracking location error: $e'));
  }

  void _fitBounds(LatLng a, LatLng b) {
    if (_mapController == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _listenForCompletion() {
    if (widget.tripId.isEmpty) return;
    _tripSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || !mounted) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'on_trip';

      if (status == 'completed') {
        _tripSubscription?.cancel();
        if (!mounted) return;

        final totalFare = ((data['final_fare'] ??
                data['estimated_fare'] ??
                widget.estimatedFare) as num)
            .toDouble();

        final pickupAddress =
            (data['pickup'] as Map<String, dynamic>?)?['address'] as String? ??
                '';
        final dropAddress =
            (data['destination'] as Map<String, dynamic>?)?['address']
                    as String? ??
                widget.dropAddress;
        final paymentMethod =
            data['payment_method'] as String? ?? 'cash';
        final ambulanceType =
            data['ambulance_type'] as String? ?? widget.ambulanceType;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, _) => TripCompletedScreen(
              tripId: widget.tripId,
              driverName: widget.driverName,
              ambulanceType: ambulanceType,
              pickupAddress: pickupAddress,
              dropAddress: dropAddress,
              totalFare: totalFare,
              paymentMethod: paymentMethod,
            ),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      } else if (status == 'cancelled') {
        _tripSubscription?.cancel();
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
        _showToast('Trip was cancelled', isError: true);
      }
    }, onError: (e) {
      debugPrint('LiveTrackingScreen listener error: $e');
    });
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _callDriver() async {
    if (widget.driverPhone.isEmpty) {
      _showToast("No driver phone number available", isError: true);
      return;
    }
    final uri = Uri(scheme: 'tel', path: widget.driverPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLatLng ?? _pickupLatLng,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() {
                  _markers = {
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: _pickupLatLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      infoWindow: const InfoWindow(title: 'Patient pickup'),
                    ),
                  };
                });
              },
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          
          // Floating Bottom Navigation Pill (like original tracking screen)
          Positioned(
             top: MediaQuery.of(context).padding.top + 10,
             left: 16,
             child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                   width: 44,
                   height: 44,
                   decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                         BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4)
                         )
                      ]
                   ),
                   child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
             )
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
                    // Drag handle
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
                            // ── A. Driver / Journey Card ──
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

  // ── Driver + Journey Card ───────────────────────────────────────
  Widget _buildDriverCard() {
    String typeLabel = 'BLS';
    Color badgeColor = const Color(0xFF1A6FE8);
    if (widget.ambulanceType == 'ALS') { typeLabel = 'ALS'; badgeColor = const Color(0xFF003366); }
    else if (widget.ambulanceType == 'Bike') { typeLabel = 'Ambu Bike'; badgeColor = const Color(0xFF10B981); }
    else if (widget.ambulanceType == 'LastRide') { typeLabel = 'Last Ride'; badgeColor = const Color(0xFF6B7280); }

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
                child: Center(child: Text(widget.driverName.isNotEmpty ? widget.driverName[0].toUpperCase() : 'DK', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A0F1E))),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text('$typeLabel Paramedic · ', style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
                        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                        const Text(' 4.9', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${widget.vehicleNumber} · ${widget.ambulanceType == 'Bike' ? 'Honda Activa' : 'Mahindra Bolero'}',
                        style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                     onTap: _callDriver,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pickup', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 12)),
              Text(widget.dropAddress.isNotEmpty ? widget.dropAddress : 'Hospital', style: const TextStyle(color: Color(0xFF1A6FE8), fontSize: 12, fontWeight: FontWeight.bold)),
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
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.dropAddress.isNotEmpty ? widget.dropAddress : 'Hospital',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A0F1E)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                const Text('Heading to destination',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total distance', style: TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
                const SizedBox(height: 6),
                const Text('3.2 km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A0F1E))),
                const SizedBox(height: 2),
                Text('Est. ₹${widget.estimatedFare.toInt()} fare', style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Emergency contact card
        Expanded(
          child: GestureDetector(
             onTap: () => _showToast('Calling Emergency Contact...'),
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
            'Live tracking enabled',
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
