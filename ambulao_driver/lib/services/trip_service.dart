import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_provider.dart';

// Simulates a backend service that listens for and dispatches trips
class TripService {
  final Ref _ref;
  Timer? _mockRequestTimer;

  TripService(this._ref);

  // Simulates connecting to a WebSocket or FCM and getting a trip dispatch
  void startListeningForRequests() {
    // For demonstration, trigger a mock request after 5 seconds of idle state
    _mockRequestTimer?.cancel();
    _mockRequestTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentData = _ref.read(tripProvider);
      if (currentData.state == TripState.idle) {
        // Dispatch incoming request
        _ref.read(tripProvider.notifier).simulateIncomingRequest();
      }
    });
  }

  void stopListening() {
    _mockRequestTimer?.cancel();
  }
}

// Global provider for the trip service
final tripServiceProvider = Provider<TripService>((ref) {
  final service = TripService(ref);
  // Start listening automatically when the service is instantiated
  service.startListeningForRequests();
  return service;
});
