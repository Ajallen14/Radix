import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/i_workout_repository.dart';

// 1. DATA MODELS
class RoutineTemplate {
  final int? id;
  final String title;
  final String volume;
  final String category;

  RoutineTemplate({
    this.id,
    required this.title,
    required this.volume,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'volume': volume,
      'category': category,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory RoutineTemplate.fromMap(Map<String, dynamic> map) {
    return RoutineTemplate(
      id: map['id'],
      title: map['title'],
      volume: map['volume'],
      category: map['category'],
    );
  }
}

// 2. DATABASE & REPOSITORY PROVIDERS
// Provide SQLite database helper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Provide the Repository Interface
final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkoutRepositoryImpl(dbHelper);
});

// 3. ROUTINE MANAGEMENT
class RoutinesNotifier extends StateNotifier<List<RoutineTemplate>> {
  final IWorkoutRepository repository;

  RoutinesNotifier(this.repository) : super([]) {
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    state = await repository.getRoutines();
  }

  Future<void> addRoutine(RoutineTemplate routine) async {
    await repository.saveRoutine(routine);
    await _loadRoutines();
  }

  Future<void> deleteRoutine(int id) async {
    await repository.deleteRoutine(id);
    await _loadRoutines();
  }
}

// The updated Provider for Routines
final routinesProvider =
    StateNotifierProvider<RoutinesNotifier, List<RoutineTemplate>>((ref) {
      final repository = ref.watch(workoutRepositoryProvider);
      return RoutinesNotifier(repository);
    });

// 4. UI STATE PROVIDERS
final selectedFilterProvider = StateProvider<String>((ref) => 'All Type');
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final isWorkoutActiveProvider = StateProvider<bool>((ref) => false);
final isRestTimerActiveProvider = StateProvider<bool>((ref) => false);

final activeWorkoutIdProvider = StateProvider<int?>((ref) => null);

// 5. WORKOUT ACTIONS
final saveSetProvider = Provider((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return (String exerciseName, double weight, int reps) async {
    try {
      final currentSessionId = ref.read(activeWorkoutIdProvider);

      if (currentSessionId == null) {
        print('Error: No active workout session found!');
        return;
      }

      await repository.saveCompletedSet(
        currentSessionId,
        exerciseName,
        weight,
        reps,
      );
      print(
        'Saved to SQLite: Session $currentSessionId | $exerciseName - $weight kg x $reps',
      );
    } catch (e) {
      print('Failed to save set: $e');
    }
  };
});
