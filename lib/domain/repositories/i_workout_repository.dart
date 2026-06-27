import '../../presentation/providers/core_providers.dart';

abstract class IWorkoutRepository {
  // Routine Methods
  Future<List<RoutineTemplate>> getRoutines();
  Future<void> saveRoutine(RoutineTemplate routine);
  Future<void> deleteRoutine(int id);
  
  // Set & Session Methods
  Future<void> saveCompletedSet(int workoutId, String exerciseName, double weight, int reps);
  Future<int> createWorkoutSession(String routineName);
  Future<List<Map<String, dynamic>>> getAllWorkouts();
  
  // Analytics Methods
  Future<double> calculateTotalVolumeForSession(int workoutId);
}