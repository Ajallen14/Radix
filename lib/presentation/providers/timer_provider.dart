import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vibration/vibration.dart';

import '../screens/active_workout_screen.dart';

class RestTimerNotifier extends StateNotifier<int> {
  final Ref ref;
  Timer? _countdownTimer;
  Timer? _vibrateTimer;

  RestTimerNotifier(this.ref) : super(0);

  void start(int seconds) {
    _countdownTimer?.cancel();
    _vibrateTimer?.cancel();
    Vibration.cancel(); // Ensure any previous vibration is stopped

    state = seconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state--;
        // Trigger the vibration the moment it hits 0
        if (state == 0) {
          _triggerContinuousVibration();
        }
      }
    });
  }

  Future<void> _triggerContinuousVibration() async {
    _countdownTimer?.cancel();

    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Vibrate immediately for 1 second
      Vibration.vibrate(duration: 1000);

      // Then repeat the 1-second vibration every 2 seconds until stopped
      _vibrateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        Vibration.vibrate(duration: 1000);
      });
    }
  }

  void addTime(int seconds) {
    if (state == 0) {
      // If you add time AFTER it hit 0, stop the vibration and restart the clock
      _vibrateTimer?.cancel();
      Vibration.cancel();
      start(seconds);
    } else {
      state += seconds;
    }
  }

  void stop() {
    // Kill all timers and vibrations
    _countdownTimer?.cancel();
    _vibrateTimer?.cancel();
    Vibration.cancel();

    state = 0;
    ref.read(isRestTimerActiveProvider.notifier).state = false;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _vibrateTimer?.cancel();
    Vibration.cancel();
    super.dispose();
  }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, int>((ref) {
  return RestTimerNotifier(ref);
});
