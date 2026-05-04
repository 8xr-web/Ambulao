import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final VoidCallback onPhoneShake;
  final double shakeThresholdGravity;
  final int shakeSlopTimeMS;
  final int shakeCountResetTime;

  int mShakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int mShakeCount = 0;
  StreamSubscription? streamSubscription;

  ShakeDetector({
    required this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
  });

  factory ShakeDetector.autoStart({
    required VoidCallback onPhoneShake,
    double shakeThresholdGravity = 2.7,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
  }) {
    final detector = ShakeDetector(
      onPhoneShake: onPhoneShake,
      shakeThresholdGravity: shakeThresholdGravity,
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeCountResetTime: shakeCountResetTime,
    );
    detector.startListening();
    return detector;
  }

  void startListening() {
    streamSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        double x = event.x;
        double y = event.y;
        double z = event.z;

        double gX = x / 9.80665;
        double gY = y / 9.80665;
        double gZ = z / 9.80665;

        // gForce will be close to 1 when there is no movement.
        double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          var now = DateTime.now().millisecondsSinceEpoch;
          // ignore shake events too close to each other
          if (mShakeTimestamp + shakeSlopTimeMS > now) {
            return;
          }

          // reset the shake count after 3 seconds of no shakes
          if (mShakeTimestamp + shakeCountResetTime < now) {
            mShakeCount = 0;
          }

          mShakeTimestamp = now;
          mShakeCount++;

          onPhoneShake();
        }
      },
      onError: (error) {
        debugPrint('ShakeDetector error: $error');
      },
    );
  }

  void stopListening() {
    streamSubscription?.cancel();
  }
}
