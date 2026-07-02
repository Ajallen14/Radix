import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/i_workout_repository.dart';

// DATA MODELS
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

// DATABASE & REPOSITORY PROVIDERS
// Provide SQLite database helper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Provide the Repository Interface
final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WorkoutRepositoryImpl(dbHelper);
});

// ROUTINE MANAGEMENT
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

// UI STATE PROVIDERS
final selectedFilterProvider = StateProvider<String>((ref) => 'All Type');
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final isWorkoutActiveProvider = StateProvider<bool>((ref) => false);
final isRestTimerActiveProvider = StateProvider<bool>((ref) => false);

final activeWorkoutIdProvider = StateProvider<int?>((ref) => null);

// WORKOUT ACTIONS
final saveSetProvider = Provider((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return (String exerciseName, double weight, int reps) async {
    try {
      final currentSessionId = ref.read(activeWorkoutIdProvider);

      if (currentSessionId == null) {
        return;
      }

      await repository.saveCompletedSet(
        currentSessionId,
        exerciseName,
        weight,
        reps,
      );
    // ignore: empty_catches
    } catch (e) {
    }
  };
});

// Fetches all raw workout sessions
final recentWorkoutsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getAllWorkouts();
});

// Processes the data into specific metrics
final analyticsStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final workouts = await ref.watch(recentWorkoutsProvider.future);

  Set<String> allActiveDates = {}; 
  int daysWorkedOutThisMonth = 0;
  int maxSets = 0;
  final now = DateTime.now();

  Map<int, double> weeklySets = {
    for (var i = 6; i >= 0; i--) now.subtract(Duration(days: i)).weekday: 0.0,
  };

  for (var workout in workouts) {
    final date = DateTime.parse(workout['date']);
    final workoutId = workout['id'] as int;

    allActiveDates.add('${date.year}-${date.month}-${date.day}');

    if (date.month == now.month && date.year == now.year) {
      daysWorkedOutThisMonth++;
    }

    final setsCount = await repository.calculateTotalSetsForSession(workoutId);
    if (setsCount > maxSets) maxSets = setsCount;

    final difference = now.difference(date).inDays;
    if (difference < 7 && difference >= 0) {
      weeklySets[date.weekday] = (weeklySets[date.weekday] ?? 0) + setsCount.toDouble();
    }
  }

  return {
    'monthlyDays': daysWorkedOutThisMonth,
    'maxSets': maxSets,
    'weeklySets': weeklySets,
    'allActiveDates': allActiveDates, 
  };
});

// WEEKLY SCHEDULE PLANNER
class WeeklyScheduleNotifier extends StateNotifier<Map<int, String>> {
  final IWorkoutRepository repository;

  WeeklyScheduleNotifier(this.repository) : super({}) {
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    state = await repository.getWeeklySchedule();
  }

  Future<void> updateFocus(int day, String focus) async {
    await repository.updateDailyFocus(day, focus);
    await _loadSchedule();
  }
}

final weeklyScheduleProvider = StateNotifierProvider<WeeklyScheduleNotifier, Map<int, String>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WeeklyScheduleNotifier(repository);
});

final dailyExercisesProvider = FutureProvider.family<List<RoutineTemplate>, String>((ref, category) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getRoutinesByCategory(category);
});
