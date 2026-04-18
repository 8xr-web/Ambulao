import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── LISTEN FOR NEW TRIPS ─────────────────────────────
  static Stream<QuerySnapshot> listenForPendingTrips({
    required String ambulanceType,
  }) {
    return _db
        .collection('trips')
        .where('status', isEqualTo: 'searching')
        .where('ambulance_type', isEqualTo: ambulanceType)
        .snapshots();
  }

  // ─── ACCEPT TRIP ──────────────────────────────────────
  static Future<void> acceptTrip({
    required String tripId,
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String vehicleNumber,
  }) async {
    await _db.collection('trips').doc(tripId).update({
      'driver_id': driverId,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_number': vehicleNumber,
      'status': 'accepted',
      'accepted_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'estimated_time': '8',
    });

    await _db.collection('drivers').doc(driverId).set({
      'current_trip_id': tripId,
      'status': 'on_trip',
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── DECLINE TRIP ─────────────────────────────────────
  static Future<void> declineTrip(
      String tripId, String driverId) async {
    await _db.collection('trips').doc(tripId).update({
      'declined_by': FieldValue.arrayUnion([driverId]),
    });
  }

  // ─── START TRIP ───────────────────────────────────────
  static Future<void> startTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).update({
      'status': 'on_trip',
      'started_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ─── END TRIP ─────────────────────────────────────────
  static Future<void> endTrip({
    required String tripId,
    required String driverId,
    required double fare,
  }) async {
    await _db.collection('trips').doc(tripId).update({
      'status': 'completed',
      'final_fare': fare,
      'completed_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await _db.collection('drivers').doc(driverId).update({
      'current_trip_id': null,
      'status': 'online',
      'total_trips': FieldValue.increment(1),
      'total_earnings': FieldValue.increment(fare),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ─── UPDATE GPS LOCATION ──────────────────────────────
  static Future<void> updateDriverLocation({
    required String driverId,
    required double lat,
    required double lng,
  }) async {
    await _db.collection('drivers').doc(driverId).update({
      'location': {
        'lat': lat,
        'lng': lng,
        'updated_at': FieldValue.serverTimestamp(),
      },
    });
  }

  // ─── GET TRIP HISTORY (Driver) ────────────────────────
  static Future<List<Map<String, dynamic>>> getTripHistory(
      String driverId) async {
    final snapshot = await _db
        .collection('trips')
        .where('driver_id', isEqualTo: driverId)
        .where('status', isEqualTo: 'completed')
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }
}
