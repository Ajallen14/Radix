import '../../domain/repositories/i_workout_repository.dart';
import '../datasources/database_helper.dart';
import '../models/workout_set_model.dart';

class WorkoutRepositoryImpl implements IWorkoutRepository {
  final DatabaseHelper _dbHelper;

  WorkoutRepositoryImpl(this._dbHelper);

  @override
  Future<void> saveCompletedSet(
      int workoutId, String exercise, double weight, int reps) async {
    
    final newSet = WorkoutSetModel(
      workoutId: workoutId,
      exerciseName: exercise,
      weight: weight,
      reps: reps,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _dbHelper.insertSet(newSet.toMap());
  }

  @override
  Future<double> calculateTotalVolumeForSession(int workoutId) async {
    final setsData = await _dbHelper.getSetsForWorkout(workoutId);
    double totalVolume = 0;
    
    for (var map in setsData) {
      final workoutSet = WorkoutSetModel.fromMap(map);
      totalVolume += (workoutSet.weight * workoutSet.reps);
    }
    
    return totalVolume;
  }
}