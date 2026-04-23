import 'dart:async';
import 'dart:math' show pi;
import '../core/transitions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../viewmodels/booking_provider.dart';
import 'in_app_chat_screen.dart';
import 'live_tracking_screen.dart';

class AmbulanceAssignedScreen extends StatefulWidget {
  final String tripId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String ambulanceType;
  final String pickupAddress;
  final String dropAddress;
  final double estimatedFare;
  final double pickupLat;
  final double pickupLng;

  const AmbulanceAssignedScreen({
    super.key,
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.ambulanceType,
    required this.pickupAddress,
    required this.dropAddress,
    required this.estimatedFare,
    this.pickupLat = 17.4399,
    this.pickupLng = 78.3813,
  });

  @override
  State<AmbulanceAssignedScreen> createState() => _AmbulanceAssignedScreenState();
}

class _AmbulanceAssignedScreenState extends State<AmbulanceAssignedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  StreamSubscription<DocumentSnapshot>? _tripSubscription;
  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  GoogleMapController? _mapController;
  LatLng? _driverLatLng;
  late LatLng _pickupLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
        vsync: this, duration: const Duration(minutes: 1))
      ..repeat();
    _pickupLatLng = LatLng(widget.pickupLat, widget.pickupLng);
    _listenForTripUpdates();
    if (widget.driverId.isNotEmpty) _listenForDriverLocation();
  }

  void _listenForDriverLocation() {
    _locationSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .doc(widget.driverId)
        .collection('location')
        .doc('current')
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final d = snap.data()!;
      final lat = (d['lat'] as num?)?.toDouble();
      final lng = (d['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);
      setState(() {
        _driverLatLng = newPos;
        _markers = {
          Marker(
            markerId: const MarkerId('driver'),
            position: newPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: widget.driverName, snippet: 'En route'),
          ),
          Marker(
            markerId: const MarkerId('pickup'),
            position: _pickupLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'Your pickup', snippet: widget.pickupAddress),
          ),
        };
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [newPos, _pickupLatLng],
            color: const Color(0xFF1A6FE8),
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        };
      });

      // Smooth camera follow
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(newPos),
      );
    }, onError: (e) => debugPrint('Driver location error: $e'));
  }

  void _listenForTripUpdates() {
    _tripSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || !mounted) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'accepted';

      if (status == 'on_trip') {
        _tripSubscription?.cancel();
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, _) => LiveTrackingScreen(
              tripId: widget.tripId,
              driverId: widget.driverId,
              driverName: widget.driverName,
              driverPhone: widget.driverPhone,
              vehicleNumber: widget.vehicleNumber,
              ambulanceType: widget.ambulanceType,
              dropAddress: widget.dropAddress,
              estimatedFare: widget.estimatedFare,
              pickupLat: widget.pickupLat,
              pickupLng: widget.pickupLng,
            ),
            transitionsBuilder: (context, animation, _, child) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
        );
      } else if (status == 'cancelled') {
        _tripSubscription?.cancel();
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Trip was cancelled by the driver'),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        );
      }
    }, onError: (e) {
      debugPrint('AmbulanceAssignedScreen listener error: $e');
    });
  }


  @override
  void dispose() {
    _moveController.dispose();
    _tripSubscription?.cancel();
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

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
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            isError ? Colors.redAccent : const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // 1. Google Map with live driver marker
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLatLng ?? _pickupLatLng,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                // Set initial pickup marker right away
                setState(() {
                  _markers = {
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: _pickupLatLng,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                      infoWindow: InfoWindow(title: 'Your pickup', snippet: widget.pickupAddress),
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

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                context.read<BookingProvider>().setActiveAmbulanceBooking(
                      ambulanceType: widget.ambulanceType,
                      etaMinutes: 4,
                      driverName: widget.driverName,
                    );
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ]),
                child: const Center(
                    child: Icon(Icons.arrow_back,
                        color: AppColors.textPrimary)),
              ),
            ),
          ),

          // 3. Draggable Scrollable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.25,
            maxChildSize: 0.75,
            snap: true,
            snapSizes: const [0.25, 0.38, 0.75],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5))
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin:
                            const EdgeInsets.only(top: 12, bottom: 8),
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2.5)),
                      ),
                      const SizedBox(height: 16),

                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34C759),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Driver Accepted — Arriving',
                                style: TextStyle(
                                  color: Color(0xFF065F46),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Driver Card
                      _buildDriverCard(),
                      const SizedBox(height: 16),

                      // OTP Box
                      _buildOTPBox(),
                      const SizedBox(height: 16),

                      // Route summary
                      _buildRouteSummary(),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                              child: _buildActionButton(Icons.call, "Call",
                                  () => _callNumber(widget.driverPhone))),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildActionButton(
                                  Icons.chat_bubble_outline, "Chat", () {
                            Navigator.push(
                                context,
                                SmoothPageRoute(
                                    page: const InAppChatScreen()));
                          })),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            context
                                .read<BookingProvider>()
                                .clearActiveAmbulanceBooking();
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((r) => r.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFF04438), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                          ),
                          child: const Text('Cancel Booking',
                              style: TextStyle(
                                  color: Color(0xFFF04438),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notification Row
                      _buildNotificationRow(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceIcon(double angle) {
    return Transform.rotate(
      angle: angle + pi / 2,
      child: Container(
        width: 32,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 2),
                Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2))),
              ],
            ),
            const Spacer(),
            const Icon(Icons.add, color: Colors.red, size: 24),
            const Spacer(),
            Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A6FE8),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      widget.driverName.isNotEmpty
                          ? widget.driverName[0].toUpperCase()
                          : 'D',
                      style: const TextStyle(
                          color: Color(0xFF1A6FE8),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(widget.driverName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _buildAmbulanceBadge(widget.ambulanceType),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("⭐ 4.9",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(widget.vehicleNumber,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(_getAmbulanceModel(widget.ambulanceType),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Arriving",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text("~4 min",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Pulsing indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF34C759), size: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    widget.pickupAddress.isEmpty
                        ? 'Your location'
                        : widget.pickupAddress,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF374151))),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 5),
            width: 2,
            height: 20,
            color: const Color(0xFFE5E7EB),
          ),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: Color(0xFF1A6FE8), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    widget.dropAddress.isEmpty
                        ? 'Destination'
                        : widget.dropAddress,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF374151))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOTPBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Share this OTP with the paramedic",
            style: TextStyle(
                color: Color(0xFF6E6E73),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ["7", "4", "2", "9"].map((digit) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 52,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color(0xFF1A6FE8), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Text(digit,
                        style: const TextStyle(
                            color: Color(0xFF1A6FE8),
                            fontSize: 26,
                            fontWeight: FontWeight.bold))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text("Paramedic enters this OTP to start your journey",
              style:
                  TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationRow() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Text("✅", style: TextStyle(fontSize: 16)),
          SizedBox(width: 12),
          Expanded(
              child: Text("Emergency contacts have been notified",
                  style: TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildAmbulanceBadge(String type) {
    Color badgeColor;
    String label;
    switch (type.toUpperCase()) {
      case 'ALS':
        badgeColor = const Color(0xFF003366);
        label = 'ALS';
        break;
      case 'BIKE':
      case 'AMBUBIKE':
        badgeColor = const Color(0xFF10B981);
        label = 'Ambu Bike';
        break;
      case 'LASTRIDE':
        badgeColor = const Color(0xFF6B7280);
        label = 'Last Ride';
        break;
      default:
        badgeColor = const Color(0xFF1A6FE8);
        label = 'BLS';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(100),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  String _getAmbulanceModel(String type) {
    if (type.toUpperCase() == 'BIKE' || type.toUpperCase() == 'AMBUBIKE') {
      return 'Honda Activa 6G (Ambu Bike)';
    }
    if (type.toUpperCase() == 'LASTRIDE') {
      return 'Force Traveller Mortuary Van';
    }
    return 'Mahindra Bolero Ambulance';
  }
}

class _RoutePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double progress;

  _RoutePainter(this.start, this.end, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        start, end, paint..color = AppColors.primaryBlue.withValues(alpha: 0.3));
    final currentPos = Offset.lerp(start, end, progress)!;
    canvas.drawLine(
        currentPos, end, paint..color = AppColors.primaryBlue);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
