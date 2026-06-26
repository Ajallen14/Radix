abstract class IWorkoutRepository {
  Future<void> saveCompletedSet(int workoutId, String exercise, double weight, int reps);
  Future<double> calculateTotalVolumeForSession(int workoutId);
}