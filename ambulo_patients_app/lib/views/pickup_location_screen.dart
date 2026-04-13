import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/location_search_bar.dart';
import '../core/theme.dart';

class PickupLocationScreen extends StatefulWidget {
  const PickupLocationScreen({super.key});

  @override
  State<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {
  final LatLng _defaultLocation = const LatLng(17.3850, 78.4867);
  LatLng? _currentLocation;
  late final MapController _mapController;

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
          hintText: "Pickup Location",
          enabled: false,
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "btn_locate_pickup",
            onPressed: _locateMe,
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (_currentLocation != null)
            FloatingActionButton.extended(
              heroTag: "btn_confirm_pickup",
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
          initialCenter: _defaultLocation,
          initialZoom: 13.0,
          onTap: (_, point) {
            setState(() {
              _currentLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_hello_world',
          ),
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.location_on,
                      size: 40, color: AppColors.primaryBlue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
