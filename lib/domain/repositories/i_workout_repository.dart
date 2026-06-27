import '../../presentation/providers/core_providers.dart';

abstract class IWorkoutRepository {
  Future<List<RoutineTemplate>> getRoutines();
  Future<void> saveRoutine(RoutineTemplate routine);
  Future<void> deleteRoutine(int id);
  Future<void> saveCompletedSet(
    int workoutId,
    String exerciseName,
    double weight,
    int reps,
  );
  Future<int> createWorkoutSession(String routineName);
}
