import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radix/presentation/widgets/add_workout_sheet.dart';
import '../providers/core_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: 120.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 32),
              _buildDateScroller(),
              const SizedBox(height: 32),
              _buildRoutinesHeader(),
              const SizedBox(height: 16),
              _buildCategoryFilters(ref),
              const SizedBox(height: 24),
              _buildRoutinesGrid(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFA4EB3F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Focus',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chest & Shoulders',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: const Color(0xFFA4EB3F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateScroller() {
    final now = DateTime.now();
    // Calculate the Monday of the current week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Generate exactly 7 days starting from Monday
    final weekDates = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isToday =
              date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          // Placeholder logic: Highlight past days as "worked out" randomly for testing.
          // Eventually, you will query SQLite to see if date < now has a workout log.
          final hasWorkout = date.isBefore(now) && index % 2 == 0;

          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFFA4EB3F) : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isToday
                    ? const Color(0xFFA4EB3F)
                    : hasWorkout
                    ? const Color(0xFFA4EB3F)
                    : const Color(0xFF2A2A2A),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNames[date.weekday - 1],
                  style: TextStyle(
                    color: isToday ? Colors.black : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: isToday ? Colors.black : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutinesHeader() {
    return const Text(
      'Daily Program',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryFilters(WidgetRef ref) {
    final categories = ['All Type', 'Chest', 'Arms', 'Back', 'Legs', 'Core'];
    final activeFilter = ref.watch(selectedFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = activeFilter == category;

          return GestureDetector(
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state = category;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA4EB3F)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutinesGrid(BuildContext context, WidgetRef ref) {
    final allRoutines = ref.watch(routinesProvider);
    final activeFilter = ref.watch(selectedFilterProvider);
    final displayedRoutines = activeFilter == 'All Type'
        ? allRoutines
        : allRoutines
              .where((routine) => routine.category == activeFilter)
              .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedRoutines.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        if (index == displayedRoutines.length) {
          return _buildAddWorkoutCard(context);
        }

        final routine = displayedRoutines[index];
        final originalIndex = allRoutines.indexOf(routine);

        return _routineCard(context, ref, originalIndex, routine);
      },
    );
  }

  Widget _routineCard(
    BuildContext context,
    WidgetRef ref,
    int index,
    RoutineTemplate routine,
  ) {
    // 1. Define your 5 premium gradients
    final List<List<Color>> cardGradients = [
      const [Color(0xFF2B5876), Color(0xFF4E4376)],
      const [Color(0xFF1D4350), Color(0xFF041115)],
      const [Color(0xFF870000), Color(0xFF190A05)],
      const [Color(0xFF432B76), Color(0xFF2A0845)],
      const [Color(0xFF0F2027), Color(0xFF203A43)],
    ];

    // Cycle through the gradients based on the index
    final gradientColors = cardGradients[index % cardGradients.length];

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Delete Workout?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${routine.title}"?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (routine.id != null) {
                    ref
                        .read(routinesProvider.notifier)
                        .deleteRoutine(routine.id!);
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              routine.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              routine.volume,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWorkoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddWorkoutSheet(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Color(0xFFA4EB3F),
                size: 32,
              ),
              SizedBox(height: 8),
              Text('Add Workout', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
