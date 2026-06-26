import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:radix/presentation/providers/timer_provider.dart';
import '../providers/core_providers.dart';

final isWorkoutActiveProvider = StateProvider<bool>((ref) => false);
final isRestTimerActiveProvider = StateProvider<bool>((ref) => false);

final currentWorkoutNameProvider = StateProvider<String>(
  (ref) => 'Chest & Shoulders',
);
final completedSetsProvider = StateProvider<Set<String>>((ref) => {});

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(isWorkoutActiveProvider);
    final isTimerActive = ref.watch(isRestTimerActiveProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Area
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isActive
                  ? _buildActiveSession(ref)
                  : _buildPreWorkoutSetup(ref),
            ),

            // Rest Timer Overlay
            if (isTimerActive)
              Positioned(
                bottom: 130,
                left: 20,
                right: 20,
                child: _buildGlassmorphicTimer(ref),
              ),
          ],
        ),
      ),
    );
  }

  // 1. PRE-WORKOUT SETUP
  Widget _buildPreWorkoutSetup(WidgetRef ref) {
    return Column(
      key: const ValueKey('setup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Configure Workout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // list of selectable exercises
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _setupExerciseRow('Barbell Bench Press', 'Chest'),
              _setupExerciseRow('Incline Dumbbell Press', 'Chest'),
              _setupExerciseRow('Overhead Press', 'Shoulders'),
              _setupExerciseRow('Lateral Raises', 'Shoulders'),
            ],
          ),
        ),

        // Start Button
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 100,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Transition to Active Phase
                ref.read(isWorkoutActiveProvider.notifier).state = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA4EB3F),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _setupExerciseRow(String name, String muscle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                muscle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              _buildAdjuster('Sets', '3'),
              const SizedBox(width: 12),
              _buildAdjuster('Reps', '10'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjuster(String label, String val) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            val,
            style: const TextStyle(
              color: Color(0xFFA4EB3F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 2. ACTIVE SESSION
  Widget _buildActiveSession(WidgetRef ref) {
    // Fetch the dynamic workout name
    final workoutName = ref.watch(currentWorkoutNameProvider);

    return Column(
      key: const ValueKey('active'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            workoutName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildChip('Chest', true),
              _buildChip('Shoulders', false),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Exercise Cards List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              _buildActiveExerciseCard('Barbell Bench Press', ref),
              const SizedBox(height: 16),
              _buildActiveExerciseCard('Incline Dumbbell Press', ref),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFA4EB3F) : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActiveExerciseCard(String title, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  'Set',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'kg',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Reps',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Icon(Icons.check, color: Colors.white54, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Pass the exercise title so each set gets a unique ID
          _buildSetLoggingRow(title, '1', '60', '10', ref),
          _buildSetLoggingRow(title, '2', '65', '8', ref),
          _buildSetLoggingRow(title, '3', '65', '8', ref),
        ],
      ),
    );
  }

  Widget _buildSetLoggingRow(
    String exerciseName,
    String setNum,
    String weight,
    String reps,
    WidgetRef ref,
  ) {
    final uniqueSetId = '${exerciseName}_$setNum';
    final completedSets = ref.watch(completedSetsProvider);
    final isCompleted = completedSets.contains(uniqueSetId);
    final textColor = isCompleted ? Colors.white38 : Colors.white;
    final textDecoration = isCompleted
        ? TextDecoration.lineThrough
        : TextDecoration.none;
    final rowOpacity = isCompleted ? 0.5 : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Opacity(
        opacity: rowOpacity,
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                setNum,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  decoration: textDecoration,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    weight,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      decoration: textDecoration,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    reps,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      decoration: textDecoration,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: isCompleted ? Colors.white38 : const Color(0xFFA4EB3F),
                ),
                onPressed: () {
                  if (!isCompleted) {
                    ref
                        .read(completedSetsProvider.notifier)
                        .update((state) => <String>{...state, uniqueSetId});
                    ref.read(isRestTimerActiveProvider.notifier).state = true;

                    ref.read(restTimerProvider.notifier).start(10);
                  } else {
                    ref.read(completedSetsProvider.notifier).update((state) {
                      final newState = <String>{...state};
                      newState.remove(uniqueSetId);
                      return newState;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. REST TIMER
  Widget _buildGlassmorphicTimer(WidgetRef ref) {
    final secondsRemaining = ref.watch(restTimerProvider);

    final minutesStr = (secondsRemaining / 60).floor().toString().padLeft(
      2,
      '0',
    );
    final secondsStr = (secondsRemaining % 60).toString().padLeft(2, '0');
    final timeDisplay = '$minutesStr:$secondsStr';
    final buttonText = secondsRemaining == 0 ? 'Stop' : 'Skip';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rest Time',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  Text(
                    timeDisplay,
                    style: TextStyle(
                      color: secondsRemaining == 0
                          ? Colors.redAccent
                          : const Color(0xFFA4EB3F),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(restTimerProvider.notifier).addTime(30);
                    },
                    child: const Text(
                      '+30s',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(restTimerProvider.notifier).stop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondsRemaining == 0
                          ? Colors.redAccent
                          : const Color(0xFFA4EB3F),
                      foregroundColor: secondsRemaining == 0
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
