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