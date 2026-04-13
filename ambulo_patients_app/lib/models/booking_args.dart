/// Shared booking arguments passed through the entire ambulance booking flow.
class BookingArgs {
  /// Selected service type.
  /// 'BLS' | 'ALS' | 'Bike' | 'LastRide'
  final String ambulanceType;
  final String pickup;
  final String destination;
  final double? lat;
  final double? lng;
  /// Optional alternate contact mobile when booking for someone else.
  final String? forPhone;

  const BookingArgs({
    this.ambulanceType = 'BLS',
    this.pickup = 'Location',
    this.destination = 'Hospital',
    this.lat,
    this.lng,
    this.forPhone,
  });

  /// Fare in rupees for the selected ambulance type
  String get fare {
    switch (ambulanceType) {
      case 'ALS':
        return '₹999';
      case 'Bike':
        return '₹199';
      case 'LastRide':
        return '₹799';
      default:
        return '₹499'; // BLS
    }
  }

  /// Human-readable service name
  String get serviceName {
    switch (ambulanceType) {
      case 'ALS':
        return 'ALS Ambulance Service';
      case 'Bike':
        return 'Ambu Bike Service';
      case 'LastRide':
        return 'LastRide — Mortuary Service';
      default:
        return 'BLS Ambulance Service';
    }
  }

  /// Badge text for Assigned screen
  String get badge {
    switch (ambulanceType) {
      case 'ALS':
        return 'ALS';
      case 'Bike':
        return 'Bike';
      case 'LastRide':
        return 'LastRide';
      default:
        return 'BLS';
    }
  }
}
