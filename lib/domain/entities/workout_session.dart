import 'package:equatable/equatable.dart';

class WorkoutSession extends Equatable {
  final int? id;
  final DateTime date;
  final String routineName;

  const WorkoutSession({
    this.id,
    required this.date,
    required this.routineName,
  });

  @override
  List<Object?> get props => [id, date, routineName];
}