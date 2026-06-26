import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_providers.dart';
import 'home_screen.dart';

class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      const HomeScreen(),
      const Center(
        child: Text(
          'Active Workout Screen (Coming Soon)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      const Center(
        child: Text(
          'Analytics Screen (Coming Soon)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Main Content Layer
          screens[currentIndex],

          // Floating Navigation Pill Layer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 20.0,
                ),
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_rounded,
                        currentIndex: currentIndex,
                        ref: ref,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.fitness_center_rounded,
                        currentIndex: currentIndex,
                        ref: ref,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.bar_chart_rounded,
                        currentIndex: currentIndex,
                        ref: ref,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required int currentIndex,
    required WidgetRef ref,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA4EB3F) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white70,
          size: 28,
        ),
      ),
    );
  }
}
