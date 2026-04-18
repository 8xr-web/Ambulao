import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── CREATE TRIP ──────────────────────────────────────
  static Future<String> createTripRequest({
    required String ambulanceType,
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> destination,
    required String paymentMethod,
    String? patientName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef = await _db.collection('trips').add({
      'patient_id': user?.uid ?? 'anonymous',
      'patient_name': patientName ?? 'Patient',
      'driver_id': null,
      'ambulance_type': ambulanceType,
      'pickup': pickup,
      'destination': destination,
      'payment_method': paymentMethod,
      'status': 'searching',
      'declined_by': [],
      'estimated_fare': _calculateFare(ambulanceType),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ─── FARE CALCULATOR ──────────────────────────────────
  static double _calculateFare(String ambulanceType) {
    switch (ambulanceType.toUpperCase()) {
      case 'BLS':
        return 350.0;
      case 'ALS':
        return 650.0;
      case 'BIKE':
      case 'AMBUBIKE':
        return 150.0;
      case 'LASTRIDE':
        return 500.0;
      default:
        return 350.0;
    }
  }

  // ─── LISTEN TO TRIP ───────────────────────────────────
  static Stream<DocumentSnapshot> getTripStream(String tripId) {
    return _db.collection('trips').doc(tripId).snapshots();
  }

  // ─── CANCEL TRIP ──────────────────────────────────────
  static Future<void> cancelTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).update({
      'status': 'cancelled',
      'cancelled_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ─── GET DRIVER DETAILS ───────────────────────────────
  static Future<Map<String, dynamic>?> getDriverDetails(
      String driverId) async {
    final doc = await _db.collection('drivers').doc(driverId).get();
    return doc.data();
  }

  // ─── GET TRIP HISTORY (Patient) ───────────────────────
  static Future<List<Map<String, dynamic>>> getTripHistory(
      String uid) async {
    final snapshot = await _db
        .collection('trips')
        .where('patient_id', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }
}
