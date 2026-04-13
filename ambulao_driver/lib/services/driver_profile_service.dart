import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverProfileService {
  static const String _collection = 'drivers';

  static Future<void> saveField(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('driver_uid') ?? '';

    if (value is String) await prefs.setString('profile_$key', value);
    if (value is bool) await prefs.setBool('profile_$key', value);
    if (value is int) await prefs.setInt('profile_$key', value);
    if (value is double) await prefs.setDouble('profile_$key', value);

    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .set({key: value, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    }
  }

  static Future<Map<String, dynamic>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('driver_uid') ?? '';

    if (uid.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .get();
      if (doc.exists) return doc.data() ?? {};
    }
    return {};
  }

  static Stream<DocumentSnapshot> profileStream(String uid) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(uid)
        .snapshots();
  }
}
