import 'package:equatable/equatable.dart';

class ExerciseSet extends Equatable {
  final int? id;
  final int workoutId;
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime completedAt;

  const ExerciseSet({
    this.id,
    required this.workoutId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        workoutId,
        exerciseName,
        weight,
        reps,
        completedAt,
      ];
}