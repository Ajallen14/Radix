import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../providers/core_providers.dart';

final viewedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final defaultRestDurationProvider = StateProvider<int>((ref) => 90);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(analyticsStatsProvider);
    final recentAsync = ref.watch(recentWorkoutsProvider);

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
              const Text(
                'Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              statsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFA4EB3F)),
                ),
                error: (err, stack) => Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
                data: (stats) => Column(
                  children: [
                    _buildWeeklyChart(
                      stats['weeklyVolume'] as Map<int, double>,
                    ),
                    const SizedBox(height: 24),
                    _buildMetricCards(
                      stats['monthlyDays'] as int,
                      stats['maxVolume'] as double,
                    ),
                    const SizedBox(height: 24),
                    _buildMonthlyCalendar(
                      stats['allActiveDates'] as Set<String>,
                      ref,
                    ),
                    const SizedBox(height: 24),
                    _buildRestTimerSetting(ref, context),
                    const SizedBox(height: 24),
                    _buildWeeklySplitPlanner(context, ref),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Recent Sessions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              recentAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
                data: (workouts) => _buildRecentWorkoutsList(workouts),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WEEKLY ACTIVITY CHART
  Widget _buildWeeklyChart(Map<int, double> weeklyData) {
    final maxChartY = weeklyData.values.isEmpty
        ? 1000.0
        : weeklyData.values.reduce((curr, next) => curr > next ? curr : next) *
              1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Volume',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxChartY == 0 ? 100 : maxChartY,
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value.toInt() < 1 || value.toInt() > 7) {
                          return const Text('');
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt() - 1],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: weeklyData.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        width: 16,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA4EB3F), Color(0xFF6DA026)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxChartY == 0 ? 100 : maxChartY,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // METRIC CARDS
  Widget _buildMetricCards(int monthlyDays, double maxVolume) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            title: 'Days This Month',
            value: monthlyDays.toString(),
            icon: Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metricCard(
            title: 'Max Volume (kg)',
            value: maxVolume.toStringAsFixed(0),
            icon: Icons.fitness_center_rounded,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFA4EB3F), size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // MONTHLY CONSISTENCY GRID
  Widget _buildMonthlyCalendar(Set<String> allActiveDates, WidgetRef ref) {
    final viewedMonth = ref.watch(viewedMonthProvider);
    final now = DateTime.now();

    final daysInMonth = DateTime(
      viewedMonth.year,
      viewedMonth.month + 1,
      0,
    ).day;
    final currentMonthName = DateFormat('MMMM yyyy').format(viewedMonth);
    final isCurrentMonth =
        viewedMonth.year == now.year && viewedMonth.month == now.month;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Consistency Grid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_left, color: Colors.white54),
                    onPressed: () {
                      ref
                          .read(viewedMonthProvider.notifier)
                          .update(
                            (state) => DateTime(state.year, state.month - 1),
                          );
                    },
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(
                      currentMonthName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.chevron_right,
                      color: isCurrentMonth
                          ? Colors.transparent
                          : Colors.white54,
                    ),
                    onPressed: isCurrentMonth
                        ? null
                        : () {
                            ref
                                .read(viewedMonthProvider.notifier)
                                .update(
                                  (state) =>
                                      DateTime(state.year, state.month + 1),
                                );
                          },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final dayNumber = index + 1;
              final dateString =
                  '${viewedMonth.year}-${viewedMonth.month}-$dayNumber';
              final isActive = allActiveDates.contains(dateString);
              final isToday =
                  dayNumber == now.day &&
                  viewedMonth.month == now.month &&
                  viewedMonth.year == now.year;

              return Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFA4EB3F)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.white54,
                      fontWeight: isActive || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // OPTION TO SET DEFAULT REST TIME Preference
  Widget _buildRestTimerSetting(WidgetRef ref, BuildContext context) {
    final currentRest = ref.watch(defaultRestDurationProvider);
    final displayMinutes = (currentRest / 60).floor();
    final displaySeconds = (currentRest % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFFA4EB3F),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Default Rest Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Triggered when marking a set completed',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showRestTimePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFA4EB3F).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$displayMinutes:$displaySeconds',
                    style: const TextStyle(
                      color: Color(0xFFA4EB3F),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFA4EB3F),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          // Read current duration inside the builder so the UI updates as you drag
          final currentRest = ref.watch(defaultRestDurationProvider);
          final minutes = (currentRest / 60).floor();
          final seconds = (currentRest % 60).toString().padLeft(2, '0');

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Default Rest Interval',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Huge real-time dynamic text display
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    color: Color(0xFFA4EB3F),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),

                // Custom styled Material Slider (Scroller)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFA4EB3F),
                    inactiveTrackColor: const Color(0xFF2A2A2A),
                    thumbColor: const Color(0xFFA4EB3F),
                    overlayColor: const Color(0xFFA4EB3F).withOpacity(0.2),
                    trackHeight: 6.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12.0,
                    ),
                  ),
                  child: Slider(
                    value: currentRest.toDouble(),
                    min: 15, // Starts at 15 seconds
                    max: 180, // Max of 3 minutes
                    divisions: 11, // Exactly 11 steps of 15 seconds each
                    onChanged: (value) {
                      ref.read(defaultRestDurationProvider.notifier).state =
                          value.toInt();
                    },
                  ),
                ),

                // Min/Max labels under the slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '15s',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '3m',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4EB3F),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // RECENT WORKOUTS LIST (MAX 15 SESSIONS CAP)
  Widget _buildRecentWorkoutsList(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'No sessions recorded yet.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final displayCount = math.min(workouts.length, 15);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final date = DateTime.parse(workout['date']);
        final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);

        return Container(
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
                    workout['routine_name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        );
      },
    );
  }

  // WEEKLY SPLIT PLANNER
  Widget _buildWeeklySplitPlanner(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(weeklyScheduleProvider);
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Weekly Split',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final dayNumber = index + 1;
            final currentFocus = schedule[dayNumber] ?? 'Rest';
            final isRestDay = currentFocus == 'Rest';

            return GestureDetector(
              onTap: () =>
                  _showFocusPicker(context, ref, dayNumber, days[index]),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRestDay
                        ? Colors.transparent
                        : const Color(0xFFA4EB3F).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      days[index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              currentFocus,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isRestDay
                                    ? Colors.white38
                                    : const Color(0xFFA4EB3F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.edit_calendar_rounded,
                            color: Colors.white38,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showFocusPicker(
    BuildContext context,
    WidgetRef ref,
    int dayNumber,
    String dayName,
  ) {
    final options = [
      'Chest',
      'Back',
      'Arms',
      'Legs',
      'Shoulders',
      'Core',
      'Full Body',
    ];

    final currentFocusString =
        ref.read(weeklyScheduleProvider)[dayNumber] ?? 'Rest';
    Set<String> selectedOptions = currentFocusString == 'Rest'
        ? {}
        : currentFocusString.split(' & ').toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set focus for $dayName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...options.map((option) {
                      final isSelected = selectedOptions.contains(option);

                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        backgroundColor: const Color(0xFF2A2A2A),
                        selectedColor: const Color(0xFFA4EB3F),
                        checkmarkColor: Colors.black,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (option == 'Full Body') {
                              selectedOptions = {'Full Body'};
                            } else {
                              selectedOptions.remove('Full Body');
                              if (selected) {
                                selectedOptions.add(option);
                              } else {
                                selectedOptions.remove(option);
                              }
                            }
                          });
                        },
                      );
                    }),

                    FilterChip(
                      label: const Text('Rest'),
                      selected: selectedOptions.isEmpty,
                      backgroundColor: const Color(0xFF2A2A2A),
                      selectedColor: const Color(0xFFA4EB3F),
                      checkmarkColor: Colors.black,
                      labelStyle: TextStyle(
                        color: selectedOptions.isEmpty
                            ? Colors.black
                            : Colors.white,
                        fontWeight: selectedOptions.isEmpty
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedOptions.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4EB3F),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final newFocus = selectedOptions.isEmpty
                          ? 'Rest'
                          : selectedOptions.join(' & ');
                      ref
                          .read(weeklyScheduleProvider.notifier)
                          .updateFocus(dayNumber, newFocus);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Save Split',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
