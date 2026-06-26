import 'package:radix/domain/entities/exercise_set.dart';

class WorkoutSetModel {
  final int? id;
  final int workoutId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int completedAt;

  WorkoutSetModel({
    this.id,
    required this.workoutId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_name': exerciseName,
      'weight': weight,
      'reps': reps,
      'completed_at': completedAt,
    };
  }

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int,
      exerciseName: map['exercise_name'] as String,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      completedAt: map['completed_at'] as int,
    );
  }

  ExerciseSet toEntity() {
  return ExerciseSet(
    id: id,
    workoutId: workoutId,
    exerciseName: exerciseName,
    weight: weight,
    reps: reps,
    completedAt: DateTime.fromMillisecondsSinceEpoch(completedAt),
  );
}
}