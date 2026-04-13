class TripRequest {
  final String patientName;
  final String patientPhone;
  final String pickupAddress;
  final String dropAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String estimatedFare;
  final String distance;
  final String duration;
  final bool isEmergency;

  TripRequest({
    required this.patientName,
    required this.patientPhone,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.estimatedFare,
    required this.distance,
    required this.duration,
    this.isEmergency = false,
  });

  static TripRequest mock() {
    return TripRequest(
      patientName: 'Rahul Kumar',
      patientPhone: '+91 9876543210',
      pickupAddress: 'Minister Road, Hyderabad 500003',
      dropAddress: 'KIMS Hospital, Secunderabad',
      pickupLat: 17.4334,
      pickupLng: 78.4866,
      dropLat: 17.4338,
      dropLng: 78.4859,
      estimatedFare: '₹380',
      distance: '2.4 km',
      duration: '8 min',
      isEmergency: true,
    );
  }
}
