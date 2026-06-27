import '../../presentation/providers/core_providers.dart';

abstract class IWorkoutRepository {
  // Routine Methods
  Future<List<RoutineTemplate>> getRoutines();
  Future<void> saveRoutine(RoutineTemplate routine);
  Future<void> deleteRoutine(int id);
  Future<List<RoutineTemplate>> getRoutinesByCategory(String category);
  
  // Set & Session Methods
  Future<void> saveCompletedSet(int workoutId, String exerciseName, double weight, int reps);
  Future<int> createWorkoutSession(String routineName);
  Future<List<Map<String, dynamic>>> getAllWorkouts();
  
  // Analytics Methods
  Future<double> calculateTotalVolumeForSession(int workoutId);

  // Weekly Schedule Methods
  Future<Map<int, String>> getWeeklySchedule();
  Future<void> updateDailyFocus(int day, String focus);
}