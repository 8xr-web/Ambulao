import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ambulao_driver/core/theme.dart';

class MapBackgroundMock extends StatefulWidget {
  final Widget child;

  const MapBackgroundMock({super.key, required this.child});

  @override
  State<MapBackgroundMock> createState() => _MapBackgroundMockState();
}

class _MapBackgroundMockState extends State<MapBackgroundMock> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(17.3850, 78.4867), // Hyderabad Center
            initialZoom: 13.5,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.example.ambulao_driver',
            ),
            MarkerLayer(
              markers: [
                // NIMS Hospital
                Marker(
                  point: const LatLng(17.4217, 78.4552),
                  width: 120,
                  height: 60,
                  child: _buildMockMarker('NIMS Hospital'),
                ),
                // Apollo Jubilee Hills
                Marker(
                  point: const LatLng(17.4147, 78.4124),
                  width: 140,
                  height: 60,
                  child: _buildMockMarker('Apollo Jubilee Hills'),
                ),
              ],
            ),
          ],
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }

  Widget _buildMockMarker(String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
