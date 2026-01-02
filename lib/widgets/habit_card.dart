import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/habit_provider.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final color = habit.isPositive ? Colors.greenAccent : Colors.redAccent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Streak: ${habit.currentStreak}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                if (habit.isPositive) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    tooltip: 'Reset Streak / Penalty',
                    onPressed: () {
                      ref
                          .read(habitControllerProvider.notifier)
                          .performHabit(habit, false);
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      tooltip: 'Complete (+${habit.xpReward} XP)',
                      onPressed: () {
                        ref
                            .read(habitControllerProvider.notifier)
                            .performHabit(habit, true);
                      },
                    ),
                  ),
                ] else ...[
                  // For negative habits, usually just a "Bad" button?
                  // Or "Avoided" (+) vs "Did it" (-).
                  // Let's implement (-) as "Did it" (Penalty)
                  // The (+) could be "Good job avoiding" (Reward).
                  // Keeping it simpler: Only (-) button for now to register the bad habit. Experimental (+) for avoiding.
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    tooltip: 'I did it... (-${habit.xpPenalty} XP)',
                    onPressed: () {
                      ref
                          .read(habitControllerProvider.notifier)
                          .performHabit(habit, false);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
