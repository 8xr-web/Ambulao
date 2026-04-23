import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserProvider extends ChangeNotifier {
  String name = '';
  String phone = '9876543210';
  String email = '';
  String dob = '';
  String gender = 'Male';
  String address = 'Fetching location...';
  double? latitude;
  double? longitude;
  String? photoPath; // for profile photo

  Position? get currentLocation => (latitude != null && longitude != null) 
    ? Position(latitude: latitude!, longitude: longitude!, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0)
    : null;

  List<Map<String, String>> emergencyContacts = [
    {'name': 'Priya Kumar', 'relation': 'Wife', 'phone': '+91 98765 43210'},
    {'name': 'Ravi Kumar', 'relation': 'Brother', 'phone': '+91 98765 43211'},
  ];

  UserProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('user_name') ?? prefs.getString('patient_name') ?? '';
    phone = prefs.getString('user_phone') ?? '9876543210';
    email = prefs.getString('user_email') ?? '';
    dob = prefs.getString('user_dob') ?? '';
    gender = prefs.getString('user_gender') ?? 'Male';
    address = prefs.getString('user_address') ?? 'Fetching location...';
    latitude = prefs.getDouble('user_latitude');
    longitude = prefs.getDouble('user_longitude');
    photoPath = prefs.getString('user_photoPath');
    
    // Auto-fetch location on load if not already set or as a refresh
    fetchCurrentLocation();

    final contactsRaw = prefs.getString('emergency_contacts');
    if (contactsRaw != null) {
      final List decoded = jsonDecode(contactsRaw);
      emergencyContacts = decoded.map((e) => Map<String, String>.from(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_email', email);
    await prefs.setString('user_dob', dob);
    await prefs.setString('user_gender', gender);
    await prefs.setString('user_address', address);
    if (latitude != null) await prefs.setDouble('user_latitude', latitude!);
    if (longitude != null) await prefs.setDouble('user_longitude', longitude!);
    if (photoPath != null) {
      await prefs.setString('user_photoPath', photoPath!);
    } else {
      await prefs.remove('user_photoPath');
    }
    await prefs.setString('emergency_contacts', jsonEncode(emergencyContacts));
  }

  void updateProfile({
    required String name,
    required String email,
    required String dob,
    required String gender,
    required String address,
  }) {
    this.name = name;
    this.email = email;
    this.dob = dob;
    this.gender = gender;
    this.address = address;
    _saveData();
    notifyListeners(); // this triggers ProfileScreen to rebuild
  }

  void updatePhone(String newPhone) {
    phone = newPhone;
    _saveData();
    notifyListeners();
  }

  void updatePhoto(String? path) {
    if (path == null || path.isEmpty) {
      photoPath = null;
    } else {
      photoPath = path;
    }
    _saveData();
    notifyListeners();
  }

  void updateEmergencyContacts(List<Map<String, String>> newContacts) {
    emergencyContacts = List.from(newContacts);
    _saveData();
    notifyListeners();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        // We can't request permissions anymore
        debugPrint('Location permissions are denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      latitude = position.latitude;
      longitude = position.longitude;

      if (kIsWeb) {
        // Geocoding package does not support web. Use fallback or coords.
        address = "Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        debugPrint('Web location detected: $address');
        notifyListeners();
        return;
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Formatting address as "SubLocality, Locality"
        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';
        
        if (subLocality.isNotEmpty && locality.isNotEmpty) {
          address = '$subLocality, $locality';
        } else if (locality.isNotEmpty) {
          address = locality;
        } else {
          address = 'Unknown Location';
        }
      }
      
      _saveData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching location: $e');
      // Keep previous address or set to user-friendly fallback
      if (address == 'Fetching location...') {
        address = 'Select your location';
        notifyListeners();
      }
    }
  }

  // Helper: initials from name (e.g. 'Arjun Kumar' -> 'AK')
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isEmpty ? '?' : parts[0][0].toUpperCase();
  }
}
