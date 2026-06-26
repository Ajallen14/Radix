import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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

            // Date Scroller
            _buildDateScroller(),
            const SizedBox(height: 32),

            // 'Daily Program' Header
            _buildRoutinesHeader(),
            const SizedBox(height: 16),

            // Category Filters
            _buildCategoryFilters(),
            const SizedBox(height: 24),

            // 5. The Routines Grid
            _buildRoutinesGrid(),
          ],
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
    // Mock data for demonstration.
    final List<Map<String, dynamic>> weekDays = [
      {'day': 'Mon', 'date': '22', 'isToday': false, 'hasWorkout': true},
      {'day': 'Tue', 'date': '23', 'isToday': false, 'hasWorkout': false},
      {'day': 'Wed', 'date': '24', 'isToday': false, 'hasWorkout': true},
      {'day': 'Thu', 'date': '25', 'isToday': true, 'hasWorkout': false},
      {'day': 'Fri', 'date': '26', 'isToday': false, 'hasWorkout': false},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: day['isToday']
                  ? const Color(0xFFA4EB3F)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: day['isToday']
                    ? const Color(0xFFA4EB3F)
                    : day['hasWorkout']
                    ? const Color(
                        0xFFA4EB3F,
                      )
                    : const Color(0xFF2A2A2A),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day['day'],
                  style: TextStyle(
                    color: day['isToday'] ? Colors.black : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day['date'],
                  style: TextStyle(
                    color: day['isToday'] ? Colors.black : Colors.white,
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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daily Program',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All Type', 'Chest', 'Arms', 'Core', 'Legs'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
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
              categories[index],
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutinesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _routineCard('Chest Program', '4 Sets • 20 Reps', [
          const Color(0xFF2B5876),
          const Color(0xFF4E4376),
        ]),
        _routineCard('Arms Program', '3 Sets • 12 Reps', [
          const Color(0xFF1D4350),
          const Color(0xFF041115),
        ]),

        // Add Workout Card button
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
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
                  size: 40,
                ),
                SizedBox(height: 8),
                Text('Add Workout', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _routineCard(String title, String volume, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            volume,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
