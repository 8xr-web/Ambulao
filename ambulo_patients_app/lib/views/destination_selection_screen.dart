import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  GoogleMapController? _mapController;
  LatLng? _selectedDestination;
  static const LatLng _defaultLocation = LatLng(17.3850, 78.4867);

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    if (_selectedDestination != null) {
      Navigator.of(context).pop(_selectedDestination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = widget.initialLocation ?? _defaultLocation;

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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialTarget,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onMapCreated: (controller) => _mapController = controller,
        onTap: (point) {
          setState(() {
            _selectedDestination = point;
          });
        },
        markers: {
          if (widget.initialLocation != null)
            Marker(
              markerId: const MarkerId('pickup'),
              position: widget.initialLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Starting location'),
            ),
          if (_selectedDestination != null)
            Marker(
              markerId: const MarkerId('destination'),
              position: _selectedDestination!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'Destination'),
            ),
        },
      ),
    );
  }
}
