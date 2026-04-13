import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/trip_model.dart';

// Represents the different phases of an ambulance trip.
enum TripState {
  idle,
  requestIncoming,
  accepted,
  navigatingToPatient,
  patientPickedUp,
  navigatingToHospital,
  completed,
}

class TripData {
  final TripState state;
  final TripRequest? currentTrip;

  TripData({required this.state, this.currentTrip});

  TripData copyWith({TripState? state, TripRequest? currentTrip}) {
    return TripData(
      state: state ?? this.state,
      currentTrip: currentTrip ?? this.currentTrip,
    );
  }
}

class TripNotifier extends Notifier<TripData> {
  @override
  TripData build() => TripData(state: TripState.idle);

  // Transition to incoming request
  void simulateIncomingRequest() {
    state = state.copyWith(
      state: TripState.requestIncoming,
      currentTrip: TripRequest.mock(),
    );
  }

  // Driver accepts the trip
  void acceptTrip() {
    if (state.state == TripState.requestIncoming) {
      state = state.copyWith(state: TripState.accepted);
      // Once accepted, usually immediately transition to navigating
      Future.delayed(const Duration(milliseconds: 500), () {
        if (state.state == TripState.accepted) {
          state = state.copyWith(state: TripState.navigatingToPatient);
        }
      });
    }
  }

  // Driver arrives at patient location
  void arriveAtPatient() {
    if (state.state == TripState.navigatingToPatient) {
      state = state.copyWith(state: TripState.patientPickedUp);
    }
  }

  // Start driving to hospital
  void startTripToHospital() {
    if (state.state == TripState.patientPickedUp) {
      state = state.copyWith(state: TripState.navigatingToHospital);
    }
  }

  // Trip completed at hospital
  void completeTrip() {
    if (state.state == TripState.navigatingToHospital) {
      state = state.copyWith(state: TripState.completed);
    }
  }

  // Cancel or reset trip manually
  void resetTrip() {
    state = TripData(state: TripState.idle);
  }
}

// Global provider for the trip state
final tripProvider = NotifierProvider<TripNotifier, TripData>(
  TripNotifier.new,
);
