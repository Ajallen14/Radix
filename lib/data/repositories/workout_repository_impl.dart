import 'package:radix/data/datasources/database_helper.dart';
import 'package:radix/presentation/providers/core_providers.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/i_workout_repository.dart';
import '../models/workout_set_model.dart';

class WorkoutRepositoryImpl implements IWorkoutRepository {
  final DatabaseHelper _dbHelper;

  WorkoutRepositoryImpl(this._dbHelper);

  //Routine Methods

  @override
  Future<List<RoutineTemplate>> getRoutines() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('routines');
    return List.generate(maps.length, (i) => RoutineTemplate.fromMap(maps[i]));
  }

  @override
  Future<void> saveRoutine(RoutineTemplate routine) async {
    final db = await _dbHelper.database;
    await db.insert('routines', routine.toMap());
  }

  @override
  Future<void> deleteRoutine(int id) async {
    final db = await _dbHelper.database;
    await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  //Set & Volume Methods

  @override
  Future<void> saveCompletedSet(
    int workoutId,
    String exercise,
    double weight,
    int reps,
  ) async {
    final newSet = WorkoutSetModel(
      workoutId: workoutId,
      exerciseName: exercise,
      weight: weight,
      reps: reps,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _dbHelper.insertSet(newSet.toMap());
  }

  Future<double> calculateTotalVolumeForSession(int workoutId) async {
    final setsData = await _dbHelper.getSetsForWorkout(workoutId);
    double totalVolume = 0;

    for (var map in setsData) {
      final workoutSet = WorkoutSetModel.fromMap(map);
      totalVolume += (workoutSet.weight * workoutSet.reps);
    }

    return totalVolume;
  }

  @override
  Future<int> createWorkoutSession(String routineName) async {
    final db = await _dbHelper.database;

    return await db.insert('workouts', {
      'date': DateTime.now().toIso8601String(),
      'routine_name': routineName,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    final db = await _dbHelper.database;
    return await db.query('workouts', orderBy: 'date DESC');
  }

  @override
  Future<Map<int, String>> getWeeklySchedule() async {
    final db = await _dbHelper.database;
    final maps = await db.query('weekly_schedule');
    return {for (var map in maps) map['day'] as int: map['focus'] as String};
  }

  @override
  Future<void> updateDailyFocus(int day, String focus) async {
    final db = await _dbHelper.database;
    await db.insert(
      'weekly_schedule', 
      {'day': day, 'focus': focus},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
