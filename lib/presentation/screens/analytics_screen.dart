import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/core_providers.dart';

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

              // Handle loading/error states for the stats
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

              // Handle loading/error states for the list
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

  // ==========================================
  // 1. WEEKLY ACTIVITY CHART
  // ==========================================
  Widget _buildWeeklyChart(Map<int, double> weeklyData) {
    // Determine the highest volume to scale the chart dynamically
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
                maxY: maxChartY == 0 ? 100 : maxChartY, // Fallback if no data
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
                        // Map the integer (1-7) to the day of the week
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value.toInt() < 1 || value.toInt() > 7)
                          return const Text('');
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
                    x: entry.key, // Day of the week (1-7)
                    barRods: [
                      BarChartRodData(
                        toY: entry.value, // Volume lifted
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

  // ==========================================
  // 2. METRIC CARDS
  // ==========================================
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
            value: maxVolume.toStringAsFixed(
              0,
            ), // Drop the decimals for cleaner UI
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

  // ==========================================
  // 3. RECENT WORKOUTS LIST
  // ==========================================
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
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
}
