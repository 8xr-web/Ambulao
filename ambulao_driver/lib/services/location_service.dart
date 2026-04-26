import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Broadcasts the driver's GPS position to Firestore every 5 seconds.
///
/// Firestore path written:
///   drivers/{driverId}  →  { location: { lat, lng, updated_at } }
///
/// Usage:
///   await LocationService.startTracking(driverId);   // on trip accept
///   LocationService.stopTracking();                   // on trip end / go offline
class LocationService {
  static Timer? _timer;
  static bool _isTracking = false;

  static bool get isTracking => _isTracking;

  // ─── Public API ────────────────────────────────────────────────────────────

  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<void> startTracking(String driverId) async {
    if (_isTracking) return; // already running

    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    _isTracking = true;

    // Send immediately on start, then every 5 seconds
    await _sendLocation(driverId);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isTracking) {
        timer.cancel();
        return;
      }
      await _sendLocation(driverId);
    });
  }

  static void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static Future<void> _sendLocation(String driverId) async {
    if (driverId.isEmpty) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );

      // Write to the ROOT driver document (not a subcollection).
      // Patient app reads: drivers/{driverId} → data['location']['lat/lng']
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
          'updated_at': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      // Silently continue — don't crash the app if one update fails
      // ignore: avoid_print
      print('LocationService: update failed – $e');
    }
  }
}
