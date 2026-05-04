class AppConstants {
  // Backend URL — update this if Railway URL changes
  static const String backendUrl =
      'https://ambulao-production.up.railway.app';

  // Firebase collections
  static const String tripsCollection = 'trips';
  static const String driversCollection = 'drivers';
  static const String usersCollection = 'users';
  static const String reviewsCollection = 'reviews';

  // Fare rates
  static const double blsFare = 350.0;
  static const double alsFare = 650.0;
  static const double bikeFare = 150.0;
  static const double lastRideFare = 500.0;

  // App info
  static const String supportPhone = '+918186960072';
  static const String supportEmail = 'support@ambulao.in';
}
