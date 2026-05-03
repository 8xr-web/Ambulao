import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../models/booking_args.dart';
import '../viewmodels/user_provider.dart';
import 'main_layout.dart';
import 'ambulance_selection_screen.dart';
import 'pickup_location_screen.dart';
import 'destination_selection_screen.dart';

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
  GoogleMapController? _mapController;
  final loc.Location _location = loc.Location();
  Timer? _debounce;
  List<Map<String, dynamic>> _autocompleteResults = [];
  String? _placesError;
  final String _googleApiKey = 'AIzaSyCOn3vZ5LubquMbkeE4w_onCXnuFQ1ttnU';

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
    _debounce?.cancel();
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

  Future<void> _goToBook(String destinationAddress, String? destinationArea, {double? lat, double? lng}) async {
    final user = context.read<UserProvider>();
    final String pickupAddr = _pickupOverride ?? user.address;
    
    // Attempt Geocoding if user typed text but no coordinates are attached
    double? finalLat = _pickupOverride != null ? _pickupLat : user.latitude;
    double? finalLng = _pickupOverride != null ? _pickupLng : user.longitude;

    if (_pickupOverride != null && _pickupLat == null) {
      try {
        List<Location> locations = await locationFromAddress(_pickupOverride!);
        if (locations.isNotEmpty) {
          finalLat = locations.first.latitude;
          finalLng = locations.first.longitude;
        }
      } catch (e) {
        // Fallback to user current location if we can't find the typed one
        finalLat = user.latitude;
        finalLng = user.longitude;
      }
    }

    String finalDestination;
    if (destinationArea != null && destinationArea.isNotEmpty) {
      finalDestination = '$destinationAddress, $destinationArea';
    } else {
      finalDestination = destinationAddress;
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // pop off location screen
    MainLayout.homeNavKey.currentState?.push(
      SmoothPageRoute(
        page: AmbulanceSelectionScreen(
          args: BookingArgs(
            ambulanceType: widget.ambulanceType,
            pickup: pickupAddr,
            destination: finalDestination,
            lat: finalLat ?? user.latitude,
            lng: finalLng ?? user.longitude,
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

  Future<void> _handlePickedLocation(LatLng point, {required bool isPickup}) async {
    String addr = "Selected Map Location";
    String area = "";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final name = [p.name, p.thoroughfare].where((e) => e != null && e.isNotEmpty).join(', ');
        addr = name.isNotEmpty ? name : "Selected Location";
        area = p.subLocality ?? p.locality ?? '';
      }
    } catch(e) {
      debugPrint("Reverse geocoding error: $e");
    }

    if (isPickup) {
      _selectPickup(area.isNotEmpty ? "$addr, $area" : addr, lat: point.latitude, lng: point.longitude);
    } else {
      _goToBook(addr, area, lat: point.latitude, lng: point.longitude);
    }
  }

  void _clearPickupOverride() {
    setState(() {
      _pickupOverride = null;
      _pickupCtrl.clear();
      _pickupLat = null;
      _pickupLng = null;
      _autocompleteResults.clear();
    });
  }

  Future<void> _handleAutocomplete(String input) async {
    final query = input.trim();
    if (query.isEmpty) {
      if (mounted) setState(() { 
        _autocompleteResults.clear();
        _placesError = null;
      });
      return;
    }
    
    if (mounted) setState(() => _placesError = null);

    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&components=country:in';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          if (mounted) {
            setState(() {
              _autocompleteResults = predictions.map((p) => {
                'name': p['structured_formatting']['main_text'],
                'area': p['structured_formatting']['secondary_text'] ?? '',
                'distance': ''
              }).toList();
            });
          }
        } else if (data['status'] == 'ZERO_RESULTS') {
            if (mounted) setState(() {
               _autocompleteResults.clear();
               _placesError = "No results found.";
            });
        } else {
            if (mounted) setState(() {
               _placesError = "STATUS: ${data['status']}\nFULL RESPONSE: ${response.body}";
               _autocompleteResults.clear();
            });
            debugPrint("Places API Error: ${data['error_message'] ?? data['status']}");
        }
      } else {
          if (mounted) setState(() { _placesError = "HTTP Error: ${response.statusCode}"; });
      }
    } catch (e) {
      debugPrint("Autocomplete API error: $e");
      if (mounted) setState(() { _placesError = "Exception: $e"; });
    }
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
            child: Consumer<UserProvider>(
              builder: (context, user, child) {
                final initialPos = (user.latitude != null && user.longitude != null)
                    ? LatLng(user.latitude!, user.longitude!)
                    : const LatLng(17.3850, 78.4867);

                return GoogleMap(
                  onMapCreated: (controller) async {
                    _mapController = controller;
                    var status = await Permission.locationWhenInUse.request();
                    if (status.isGranted) {
                      try {
                        var locationData = await _location.getLocation();
                        if (locationData.latitude != null && locationData.longitude != null) {
                          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
                            LatLng(locationData.latitude!, locationData.longitude!),
                            15,
                          ));
                        }
                      } catch (e) {
                        debugPrint("Location error: $e");
                      }
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: initialPos,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                );
              },
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
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), () {
                                _handleAutocomplete(val);
                              });
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

                  // —— Select location via map ——
                  GestureDetector(
                    onTap: () async {
                      if (isPickup) {
                        final LatLng? picked = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PickupLocationScreen()),
                        );
                        if (picked != null) _handlePickedLocation(picked, isPickup: true);
                      } else {
                        final user = context.read<UserProvider>();
                        final LatLng initial = LatLng(_pickupLat ?? user.latitude ?? 17.3850, _pickupLng ?? user.longitude ?? 78.4867);
                        final LatLng? picked = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DestinationSelectionScreen(initialLocation: initial)),
                        );
                        if (picked != null) _handlePickedLocation(picked, isPickup: false);
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
                          decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                          child: const Icon(Icons.map_outlined, color: Color(0xFFEA580C), size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Select via map', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Pinpoint location exactly on the map', style: TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
                        ])),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 14),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),

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

                  // —— API Error Display ——
                  if (_placesError != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                           const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                           const SizedBox(width: 8),
                           Expanded(child: Text('API Response: $_placesError', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))),
                        ]
                      )
                    ),
                  ],

                  // —— Suggested Locations based on search ——
                  if (_autocompleteResults.isNotEmpty && !hospitalTransfer) ...[
                    const Text('SUGGESTED LOCATIONS', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                    const SizedBox(height: 8),
                    ..._autocompleteResults.map((loc) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          if (isPickup) {
                            _selectPickup('${loc['name']}, ${loc['area']}');
                          } else {
                            _goToBook(loc['name'] as String, loc['area'] as String);
                          }
                        },
                        child: _buildLocationRowWidget(loc),
                      ),
                    )),
                    const SizedBox(height: 14),
                  ],

                  // —— Hospitals section (always for hospital transfer, or drop tab) ——
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

  Widget _buildLocationRowWidget(Map<String, dynamic> loc) {
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
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(11)),
          // Use location pin instead of business icon
          child: const Icon(Icons.location_on, color: Color(0xFF6E6E73), size: 22), 
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text('${loc['area']} • ${loc['distance']}', style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
        ])),
        if (_activeTab == LocTab.pickup)
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

