import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/location_search_bar.dart';
import '../core/theme.dart';

class DropoffLocationScreen extends StatefulWidget {
  final LatLng? pickupLocation;

  const DropoffLocationScreen({super.key, this.pickupLocation});

  @override
  State<DropoffLocationScreen> createState() => _DropoffLocationScreenState();
}

class _DropoffLocationScreenState extends State<DropoffLocationScreen> {
  final LatLng _defaultLocation = const LatLng(17.3850, 78.4867);
  LatLng? _currentLocation;
  late final MapController _mapController;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    if (widget.pickupLocation == null || _currentLocation == null) return;

    final start = widget.pickupLocation!;
    final end = _currentLocation!;
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          setState(() {
            _routePoints =
                coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Error fetching route: $e');
    }
  }

  Future<void> _locateMe() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showSnack('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showSnack('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showSnack('Location permissions are permanently denied.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final newLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLatLng;
      });

      _mapController.move(newLatLng, 15.0);
      _fetchRoute(); // Fetch route after locating
    } catch (e) {
      if (mounted) _showSnack('Error getting location: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLocation() {
    if (_currentLocation != null) {
      Navigator.of(context).pop(_currentLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.black26, shape: BoxShape.circle),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
            onPressed: () => Navigator.of(context).pop(),
          );
        }),
        title: const LocationSearchBar(
          hintText: "Dropoff Location",
          enabled: false,
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "btn_locate_dropoff",
            onPressed: _locateMe,
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (_currentLocation != null)
            FloatingActionButton.extended(
              heroTag: "btn_confirm_dropoff",
              onPressed: _confirmLocation,
              backgroundColor: AppColors.primaryBlue,
              label:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.check, color: Colors.white),
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.pickupLocation ?? _defaultLocation,
          initialZoom: 13.0,
          onTap: (_, point) {
            setState(() {
              _currentLocation = point;
            });
            _fetchRoute(); // Fetch route on tap
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_hello_world',
          ),
          // Draw Route Polyline
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  color: AppColors.primaryBlue,
                  strokeWidth: 4.0,
                ),
              ],
            ),
          // Fallback: Straight line if no route points but we have both locations
          if (_routePoints.isEmpty &&
              widget.pickupLocation != null &&
              _currentLocation != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [widget.pickupLocation!, _currentLocation!],
                  color: AppColors.primaryBlue.withValues(alpha: 0.5),
                  strokeWidth: 4.0,
                  pattern: const StrokePattern.dotted(),
                ),
              ],
            ),
          // Pickup Marker (Green)
          if (widget.pickupLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.pickupLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.location_on,
                      size: 50, color: Colors.green),
                ),
              ],
            ),
          // Dropoff Marker (Red) - The one we are selecting
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.location_on,
                      size: 50, color: AppColors.primaryBlue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
