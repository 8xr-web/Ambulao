import 'package:flutter/material.dart';

class NurseBooking {
  final String bookingId;
  final String nurseName;
  final String serviceLabel;
  final int durationHours;
  final int totalPrice;
  final String location;
  final String scheduledDate;
  final String startTime;
  final String endTime;

  const NurseBooking({
    required this.bookingId,
    required this.nurseName,
    required this.serviceLabel,
    required this.durationHours,
    required this.totalPrice,
    required this.location,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
  });
}

class BookingProvider extends ChangeNotifier {
  // ─── Active ambulance booking (for home banner) ───────────────
  Map<String, dynamic>? _activeAmbulanceBooking;
  Map<String, dynamic>? get activeAmbulanceBooking => _activeAmbulanceBooking;

  void setActiveAmbulanceBooking({
    required String ambulanceType,
    required int etaMinutes,
    required String driverName,
  }) {
    _activeAmbulanceBooking = {
      'ambulanceType': ambulanceType,
      'etaMinutes': etaMinutes,
      'driverName': driverName,
      'isActive': true,
    };
    notifyListeners();
  }

  void clearActiveAmbulanceBooking() {
    _activeAmbulanceBooking = null;
    notifyListeners();
  }

  // ─── Upcoming nurse bookings (for Activity screen) ────────────
  final List<NurseBooking> _upcomingNurseBookings = [];
  List<NurseBooking> get upcomingNurseBookings =>
      List.unmodifiable(_upcomingNurseBookings);

  void addNurseBooking(NurseBooking booking) {
    // Avoid duplicates by booking ID
    _upcomingNurseBookings.removeWhere((b) => b.bookingId == booking.bookingId);
    _upcomingNurseBookings.insert(0, booking);
    notifyListeners();
  }

  void removeNurseBooking(String bookingId) {
    _upcomingNurseBookings.removeWhere((b) => b.bookingId == bookingId);
    notifyListeners();
  }
}
