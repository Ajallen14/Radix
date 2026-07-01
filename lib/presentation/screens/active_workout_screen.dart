import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:radix/presentation/screens/analytics_screen.dart';
import '../providers/core_providers.dart';
import '../providers/timer_provider.dart';

// UI State Providers
final selectedExercisesProvider = StateProvider<Set<String>>((ref) => {});
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isActive
                  ? _buildActiveSession(ref)
                  : _buildPreWorkoutSetup(ref),
            ),
            if (isTimerActive)
              Positioned(
                bottom: 110,
                left: 20,
                right: 20,
                child: _buildGlassmorphicTimer(ref),
              ),
          ],
        ),
      ),
    );
  }

  // PRE-WORKOUT SETUP
  Widget _buildPreWorkoutSetup(WidgetRef ref) {
    final schedule = ref.watch(weeklyScheduleProvider);
    final today = DateTime.now().weekday;
    final focusString = schedule[today] ?? 'Rest';
    final bodyParts = focusString.split(' & ');
    final selectedExercises = ref.watch(selectedExercisesProvider);

    if (focusString == 'Rest' || focusString.isEmpty) {
      return const Center(
        child: Text(
          'Rest Day\nRecovery is key.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return Column(
      key: const ValueKey('setup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Today's Focus:\n$focusString",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: bodyParts.length,
            itemBuilder: (context, index) {
              final part = bodyParts[index];
              final routinesAsync = ref.watch(dailyExercisesProvider(part));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      part,
                      style: const TextStyle(
                        color: Color(0xFFA4EB3F),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  routinesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA4EB3F),
                      ),
                    ),
                    error: (err, _) => Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                    data: (routines) {
                      if (routines.isEmpty) {
                        return const Text(
                          'No routines found for this category.',
                          style: TextStyle(color: Colors.white54),
                        );
                      }
                      return Column(
                        children: routines.map((r) {
                          final isSelected = selectedExercises.contains(
                            r.title,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              tileColor: const Color(0xFF2A2A2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFFA4EB3F)
                                      : Colors.transparent,
                                ),
                              ),
                              title: Text(
                                r.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                r.volume,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? const Color(0xFFA4EB3F)
                                    : Colors.white38,
                              ),
                              onTap: () {
                                ref
                                    .read(selectedExercisesProvider.notifier)
                                    .update((state) {
                                      final newState = Set<String>.from(state);
                                      isSelected
                                          ? newState.remove(r.title)
                                          : newState.add(r.title);
                                      return newState;
                                    });
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: 120.0,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: selectedExercises.isEmpty
                  ? null
                  : () async {
                      final repository = ref.read(workoutRepositoryProvider);
                      final newSessionId = await repository
                          .createWorkoutSession(focusString);

                      ref.read(activeWorkoutIdProvider.notifier).state =
                          newSessionId;
                      ref.read(isWorkoutActiveProvider.notifier).state = true;
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA4EB3F),
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                disabledForegroundColor: Colors.white24,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                selectedExercises.isEmpty
                    ? 'Select Exercises'
                    : 'Start Workout',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ACTIVE SESSION
  Widget _buildActiveSession(WidgetRef ref) {
    final selectedTitles = ref.watch(selectedExercisesProvider);
    final allRoutines = ref.watch(routinesProvider);
    final selectedRoutines = allRoutines
        .where((r) => selectedTitles.contains(r.title))
        .toList();

    final Map<String, List<String>> groupedExercises = {};
    for (var routine in selectedRoutines) {
      groupedExercises
          .putIfAbsent(routine.category, () => [])
          .add(routine.title);
    }

    final foundTitles = selectedRoutines.map((r) => r.title).toSet();
    final unknownTitles = selectedTitles.difference(foundTitles);
    if (unknownTitles.isNotEmpty) {
      groupedExercises['Other'] = unknownTitles.toList();
    }

    return Column(
      key: const ValueKey('active'),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(isWorkoutActiveProvider.notifier).state = false;
                  ref.read(selectedExercisesProvider.notifier).state = {};
                  ref.read(completedSetsProvider.notifier).state = {};
                  ref.read(activeWorkoutIdProvider.notifier).state = null;
                  ref.read(isRestTimerActiveProvider.notifier).state = false;
                },
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 150, left: 20, right: 20),
            children: groupedExercises.entries.map((entry) {
              final category = entry.key;
              final exerciseTitles = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Body Part Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFA4EB3F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...exerciseTitles.map(
                    (title) => _buildActiveExerciseCard(title, ref),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveExerciseCard(String title, WidgetRef ref) {
    final allRoutines = ref.watch(routinesProvider);
    final routine = allRoutines.firstWhere(
      (r) => r.title == title,
      orElse: () => RoutineTemplate(
        title: title,
        volume: '3 Sets • 10 Reps',
        category: '',
      ),
    );

    int numSets = 3;
    String targetReps = '10';

    final parts = routine.volume.split(' • ');
    if (parts.length == 2) {
      final setString = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
      final repString = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      if (setString.isNotEmpty) numSets = int.parse(setString);
      if (repString.isNotEmpty) targetReps = repString;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
                width: 40,
                child: Text('Set', style: TextStyle(color: Colors.white54)),
              ),
              Expanded(
                child: Center(
                  child: Text('kg', style: TextStyle(color: Colors.white54)),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text('Reps', style: TextStyle(color: Colors.white54)),
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(numSets, (index) {
            return _buildSetLoggingRow(
              title,
              '${index + 1}',
              '20',
              targetReps,
              ref,
            );
          }),
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
    final isCompleted = ref.watch(completedSetsProvider).contains(uniqueSetId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              setNum,
              style: TextStyle(
                color: isCompleted ? Colors.white38 : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.transparent
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  weight,
                  style: TextStyle(
                    color: isCompleted ? Colors.white38 : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.transparent
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  reps,
                  style: TextStyle(
                    color: isCompleted ? Colors.white38 : Colors.white,
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

                  final prefSeconds = ref.read(defaultRestDurationProvider);
                  ref.read(isRestTimerActiveProvider.notifier).state = true;
                  ref.read(restTimerProvider.notifier).start(prefSeconds);

                  ref.read(saveSetProvider)(
                    exerciseName,
                    double.tryParse(weight) ?? 0,
                    int.tryParse(reps) ?? 0,
                  );
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
    );
  }

  // REST TIMER
  Widget _buildGlassmorphicTimer(WidgetRef ref) {
    final secondsRemaining = ref.watch(restTimerProvider);
    final minutesStr = (secondsRemaining / 60).floor().toString().padLeft(
      2,
      '0',
    );
    final secondsStr = (secondsRemaining % 60).toString().padLeft(2, '0');

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
                    '$minutesStr:$secondsStr',
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
                    onPressed: () =>
                        ref.read(restTimerProvider.notifier).addTime(30),
                    child: const Text(
                      '+30s',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(restTimerProvider.notifier).stop(),
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
                    child: Text(secondsRemaining == 0 ? 'Stop' : 'Skip'),
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
