import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme.dart';

class DestinationSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const DestinationSelectionScreen({super.key, this.initialLocation});

  @override
  State<DestinationSelectionScreen> createState() =>
      _DestinationSelectionScreenState();
}

class _DestinationSelectionScreenState
    extends State<DestinationSelectionScreen> {
  late final MapController _mapController;
  LatLng? _selectedDestination;
  final LatLng _defaultLocation = const LatLng(17.3850, 78.4867);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedDestination = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    if (_selectedDestination != null) {
      Navigator.of(context).pop(_selectedDestination);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.black26, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Text(
            "Select Destination",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: _selectedDestination != null
          ? FloatingActionButton.extended(
              onPressed: _confirmSelection,
              backgroundColor: AppColors.primaryBlue,
              label: const Text("Confirm Destination",
                  style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.check, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.initialLocation ?? _defaultLocation,
          initialZoom: 14.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedDestination = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_hello_world',
          ),
          if (widget.initialLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.initialLocation!,
                  width: 150,
                  height: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Starting location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              Colors.blue.withValues(alpha: 0.2), // Blue for pickup
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (_selectedDestination != null &&
              _selectedDestination != widget.initialLocation)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedDestination!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primaryBlue,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
