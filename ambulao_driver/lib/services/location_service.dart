import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Singleton service that streams the driver's GPS position to Firestore
/// every 5 seconds during an active trip.
///
/// Firestore path:  drivers/{driverId}/location/current
/// Fields written:  { lat, lng, timestamp }
///
/// Usage:
///   LocationService.instance.startTracking(driverId);   // on trip accept
///   LocationService.instance.stopTracking();             // on trip end
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Timer? _timer;
  String? _driverId;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  /// Requests location permission, then starts a 5-second periodic timer
  /// that writes the current GPS fix to Firestore.
  Future<void> startTracking(String driverId) async {
    if (_isTracking) return; // already running

    final hasPermission = await _ensurePermission();
    if (!hasPermission) {
      debugPrint('LocationService: location permission denied, tracking aborted.');
      return;
    }

    _driverId = driverId;
    _isTracking = true;

    // Write immediately on start, then every 5 s
    await _writeLocation();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _writeLocation());
    debugPrint('LocationService: started tracking for driver $_driverId');
  }

  /// Cancels the timer and clears the tracking state.
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    debugPrint('LocationService: stopped tracking for driver $_driverId');
    _driverId = null;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  Future<void> _writeLocation() async {
    if (_driverId == null || _driverId!.isEmpty) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(_driverId)
          .collection('location')
          .doc('current')
          .set({
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint(
          'LocationService: wrote (${position.latitude}, ${position.longitude}) for $_driverId');
    } catch (e) {
      debugPrint('LocationService: failed to write location – $e');
    }
  }

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('LocationService: GPS service disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }
}
