import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../models/booking_args.dart';
import '../viewmodels/user_provider.dart';
import 'main_layout.dart';
import 'ambulance_selection_screen.dart';

/// Tab enum for location selection
enum LocTab { pickup, drop }

class LocationSelectionScreen extends StatefulWidget {
  final String ambulanceType;
  final String? serviceLabel;
  final LocTab initialTab;
  final String? prefilledDrop;
  final bool isHospitalTransfer;

  const LocationSelectionScreen({
    super.key,
    required this.ambulanceType,
    this.serviceLabel,
    this.initialTab = LocTab.drop,
    this.prefilledDrop,
    this.isHospitalTransfer = false,
  });

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late LocTab _activeTab;
  late final TextEditingController _pickupCtrl;
  late final TextEditingController _dropCtrl;
  final FocusNode _focusNode = FocusNode();

  // Typed pickup override — null means "use GPS"
  String? _pickupOverride;
  double? _pickupLat;
  double? _pickupLng;

  static const List<Map<String, dynamic>> _hospitals = [
    {'name': 'Apollo Hospital', 'area': 'Jubilee Hills', 'distance': '2.3 km', 'tags': ['CGHS', 'Ayushman']},
    {'name': 'KIMS Hospital', 'area': 'Secunderabad', 'distance': '3.8 km', 'tags': ['CGHS']},
    {'name': 'Yashoda Hospital', 'area': 'Somajiguda', 'distance': '4.1 km', 'tags': ['Ayushman']},
    {'name': 'Medicover Hospital', 'area': 'Hitec City', 'distance': '5.2 km', 'tags': ['Insurance']},
  ];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _pickupCtrl = TextEditingController();
    _dropCtrl = TextEditingController(text: widget.prefilledDrop ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Ensure location is fresh
      context.read<UserProvider>().fetchCurrentLocation();
    });
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _switchTab(LocTab tab) {
    setState(() {
      _activeTab = tab;
    });
    _focusNode.requestFocus();
  }

  void _goToBook(String destinationAddress, String? destinationArea, {double? lat, double? lng}) {
    final user = context.read<UserProvider>();
    final String pickupAddr = _pickupOverride ?? user.address;
    
    String finalDestination;
    if (destinationArea != null && destinationArea.isNotEmpty) {
      finalDestination = '$destinationAddress, $destinationArea';
    } else {
      finalDestination = destinationAddress;
    }

    Navigator.of(context).pop(); // pop off location screen
    MainLayout.homeNavKey.currentState?.push(
      SmoothPageRoute(
        page: AmbulanceSelectionScreen(
          args: BookingArgs(
            ambulanceType: widget.ambulanceType,
            pickup: pickupAddr,
            destination: finalDestination,
            lat: _pickupOverride != null ? _pickupLat : user.latitude,
            lng: _pickupOverride != null ? _pickupLng : user.longitude,
          ),
        ),
      ),
    );
  }

  void _selectPickup(String location, {double? lat, double? lng}) {
    setState(() {
      _pickupOverride = location;
      _pickupCtrl.text = location;
      _pickupLat = lat;
      _pickupLng = lng;
    });
    // Switch to drop tab after selecting pickup
    _switchTab(LocTab.drop);
  }

  void _clearPickupOverride() {
    setState(() {
      _pickupOverride = null;
      _pickupCtrl.clear();
      _pickupLat = null;
      _pickupLng = null;
    });
  }

  Future<void> _handleAutocomplete(String input) async {
    // To be implemented: Integrate Google Places SDK for real autocomplete
  }

  List<Map<String, dynamic>> get _filteredHospitals {
    final query = (_activeTab == LocTab.pickup ? _pickupCtrl.text : _dropCtrl.text).toLowerCase();
    if (query.isEmpty) return _hospitals;
    return _hospitals.where((h) =>
      (h['name'] as String).toLowerCase().contains(query) ||
      (h['area'] as String).toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPickup = _activeTab == LocTab.pickup;
    final bool hospitalTransfer = widget.isHospitalTransfer;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // —— Map Background (behind everything) ——
          Positioned(
            top: 0, left: 0, right: 0,
            height: mediaQuery.size.height * 0.46,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD1E8C5),
                image: DecorationImage(
                  image: NetworkImage('https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/78.3813,17.4398,13/600x400?access_token=pk.demo'),
                  fit: BoxFit.cover,
                  onError: _mapError,
                ),
              ),
              child: CustomPaint(painter: _MapFallbackPainter()),
            ),
          ),

          // —— User dot on map ——
          Positioned(
            top: mediaQuery.size.height * 0.24,
            left: mediaQuery.size.width / 2 - 10,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              )),
            ),
          ),

          // —— FIXED HEADER — always above the suggestion sheet ——
          Positioned(
            top: 0, left: 0, right: 0,
            child: Material(
              elevation: 8,
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, mediaQuery.padding.top + 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back + Tab pill row
                    Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tab pill switcher
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(100)),
                          child: Row(children: [
                            _buildTab(LocTab.pickup, 'Pickup'),
                            _buildTab(LocTab.drop, 'Drop'),
                          ]),
                        ),
                      ),
                    ]),

                    // Service banner
                    if (widget.serviceLabel != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(100)),
                        child: Text(widget.serviceLabel!, style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                    const SizedBox(height: 12), // Added this SizedBox to separate service banner from search field
                    // Search field
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: isPickup ? _pickupCtrl : _dropCtrl,
                            focusNode: _focusNode,
                            onChanged: (val) {
                              setState(() {});
                              _handleAutocomplete(val); // Trigger autocomplete
                            },
                            decoration: InputDecoration(
                              hintText: isPickup
                                ? (hospitalTransfer ? 'Search hospital (pickup)...' : 'Enter pickup location...')
                                : 'Search hospital or destination...',
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        // Clear pickup override button
                        if (isPickup && _pickupOverride != null)
                          GestureDetector(
                            onTap: _clearPickupOverride,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(100)),
                                child: const Text('× clear', style: TextStyle(color: Color(0xFF374151), fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // —— SUGGESTION SHEET — always below the header ——
          Positioned(
            top: _headerHeight(context),
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                children: [
                  // —— Use current location (only for pickup non-hospital-transfer tab) ——
                  if (!hospitalTransfer) ...[
                    Consumer<UserProvider>(
                      builder: (context, user, _) => GestureDetector(
                        onTap: () async {
                          if (isPickup) {
                            await user.fetchCurrentLocation();
                            _selectPickup(user.address, lat: user.latitude, lng: user.longitude);
                          } else {
                            _goToBook(user.address, null, lat: user.latitude, lng: user.longitude);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 38, height: 38,
                              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                              child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(isPickup ? 'Use current location' : user.address,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(isPickup ? '${user.address} • GPS' : 'Current location',
                                style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
                            ])),
                            if (isPickup)
                              const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 14),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // —— Custom Location using typed text ——
                  if (isPickup && _pickupCtrl.text.trim().isNotEmpty) ...[
                    GestureDetector(
                      onTap: () => _selectPickup(_pickupCtrl.text.trim()),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: const BoxDecoration(color: Color(0xFFEEF4FF), shape: BoxShape.circle),
                            child: const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Use typed location', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_pickupCtrl.text.trim(), style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
                          ])),
                          const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 14),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // â”€â”€ Hospitals section (always for hospital transfer, or drop tab) â”€â”€
                  if (!isPickup || hospitalTransfer) ...[
                    const Text('NEARBY HOSPITALS', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                    const SizedBox(height: 8),
                    ..._filteredHospitals.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildHospitalRow(h),
                    )),
                    if (_filteredHospitals.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No hospitals found', style: TextStyle(color: Color(0xFF9CA3AF))),
                        ),
                      ),
                  ],

                  // Hospital pickup section (hospital transfer only)
                  if (isPickup && hospitalTransfer) ...[
                    const Text('PICKUP FROM HOSPITAL', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                    const SizedBox(height: 8),
                    ..._filteredHospitals.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _selectPickup('${h['name']}, ${h['area']}'),
                        child: _buildHospitalRowWidget(h, isPickupMode: true),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _headerHeight(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    // back row (40) + pad12 + possibly service label (28) + pad8 + search (46) + pad12 + topPad
    final baseH = topPad + 12 + 40 + 10 + 46 + 12;
    return baseH + (widget.serviceLabel != null ? 28 + 8 : 0);
  }

  static void _mapError(Object error, StackTrace? _) { /* ignore map load errors */ }

  Widget _buildTab(LocTab tab, String label) {
    final bool active = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1A6FE8) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              '$label location',
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF6B7A99),
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalRow(Map<String, dynamic> h) {
    return GestureDetector(
      onTap: () => _goToBook(h['name'] as String, h['area'] as String),
      child: _buildHospitalRowWidget(h),
    );
  }

  Widget _buildHospitalRowWidget(Map<String, dynamic> h, {bool isPickupMode = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.business_outlined, color: AppColors.primaryBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text('${h['area']} â€¢ ${h['distance']}', style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: (h['tags'] as List<String>).map((tag) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(100)),
              child: Text(tag, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )).toList()),
        ])),
        if (isPickupMode)
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 14),
      ]),
    );
  }
}

class _MapFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final road = Paint()..color = Colors.white..strokeWidth = 8..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), road);

    final block = Paint()..color = const Color(0xFFD0E8C8)..style = PaintingStyle.fill;
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 3; c++) {
        canvas.drawRect(Rect.fromLTWH(c * size.width / 3 + 10, r * size.height / 4 + 10, size.width / 3 - 20, size.height / 4 - 20), block);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

