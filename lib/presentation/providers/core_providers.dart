import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/i_workout_repository.dart';

// Provide SQLite database helper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Provide the Repository Interface
final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkoutRepositoryImpl(dbHelper);
});

// Manage the state of the Bottom Navigation Bar
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class RoutineTemplate {
  final String title;
  final String volume;
  final List<Color> gradientColors;

  RoutineTemplate(this.title, this.volume, this.gradientColors);
}

final routinesProvider = StateProvider<List<RoutineTemplate>>((ref) {
  return [
    RoutineTemplate('Chest Program', '4 Sets • 20 Reps', const [
      Color(0xFF2B5876),
      Color(0xFF4E4376),
    ]),
    RoutineTemplate('Arms Program', '3 Sets • 12 Reps', const [
      Color(0xFF1D4350),
      Color(0xFF041115),
    ]),
  ];
});

// Toggles between the Setup phase and the Active Tracking phase
final isWorkoutActiveProvider = StateProvider<bool>((ref) => false);

// Toggles the visibility of the floating rest timer
final isRestTimerActiveProvider = StateProvider<bool>((ref) => false);
