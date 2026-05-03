import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import '../viewmodels/user_provider.dart';
import '../core/theme.dart';

class HomeScreenMiniMap extends StatefulWidget {
  const HomeScreenMiniMap({super.key});

  @override
  State<HomeScreenMiniMap> createState() => _HomeScreenMiniMapState();
}

class _HomeScreenMiniMapState extends State<HomeScreenMiniMap> {
  GoogleMapController? _mapController;
  final loc.Location _location = loc.Location();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Consumer<UserProvider>(
          builder: (context, user, child) {
            final initialPos = (user.latitude != null && user.longitude != null)
                ? LatLng(user.latitude!, user.longitude!)
                : const LatLng(17.3850, 78.4867);

            return Stack(
              children: [
                GoogleMap(
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
                        debugPrint("Location error: \$e");
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
                  scrollGesturesEnabled: false,
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'mapZoomIn',
                        backgroundColor: AppColors.primaryBlue,
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'mapZoomOut',
                        backgroundColor: AppColors.primaryBlue,
                        onPressed: () {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        },
                        child: const Icon(Icons.remove, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
