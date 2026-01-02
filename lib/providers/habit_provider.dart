import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../main.dart'; // For isarProvider
import '../models/models.dart';
import '../models/models.dart';
// import 'player_provider.dart'; // Unused

// Stream provider for watching habits
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) async* {
  final isar = ref.watch(isarProvider);

  // Watch all habits
  final stream = isar.habits.where().watch(fireImmediately: true);

  await for (final habits in stream) {
    yield habits;
  }
});

class HabitController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No state to maintain directly, updates come via stream
  }

  Future<void> addHabit(
    String title, {
    bool isPositive = true,
    int reward = 10,
    int penalty = 20,
  }) async {
    final isar = ref.read(isarProvider);

    final newHabit = Habit()
      ..title = title
      ..isPositive = isPositive
      ..xpReward = reward
      ..xpPenalty = penalty
      ..currentStreak = 0;

    await isar.writeTxn(() async {
      await isar.habits.put(newHabit);
    });
  }

  Future<void> performHabit(Habit habit, bool isPositiveAction) async {
    final isar = ref.read(isarProvider);
    // final playerController = ref.read(playerControllerProvider.notifier); // Removed to avoid nested txn

    await isar.writeTxn(() async {
      final player = await isar.players.where().findFirst();

      if (isPositiveAction) {
        // POSITIVE ACTION (Did good habit)
        // Check streak logic (simple daily streak)
        final now = DateTime.now();
        final last = habit.lastCompletedDate;

        if (last != null) {
          final difference = now.difference(last).inDays;
          if (difference == 0 && now.day == last.day) {
            // Already done today, increment anyway for prototype joy
            habit.currentStreak += 1;
          } else if (difference <= 1) {
            // Consecutive day
            habit.currentStreak += 1;
          } else {
            // Broken streak
            habit.currentStreak = 1;
          }
        } else {
          habit.currentStreak = 1;
        }

        habit.lastCompletedDate = now;

        // Reward Player
        if (player != null) {
          player.currentXP += habit.xpReward.toDouble();
          player.coins += (habit.xpReward / 10).floor();

          // Heal HP on positive habit
          player.currentHP = (player.currentHP + 5).clamp(0.0, player.maxHP);

          await isar.players.put(player);
        }
      } else {
        // NEGATIVE ACTION (Did bad habit OR reset good habit)
        // Reset streak
        habit.currentStreak = 0;
        habit.lastCompletedDate = DateTime.now(); // Mark as "failed" now

        // Punish Player
        if (player != null) {
          player.currentXP = (player.currentXP - habit.xpPenalty.toDouble())
              .clamp(0.0, double.infinity);

          // Damage HP on failure/bad habit
          player.currentHP = (player.currentHP - 10).clamp(0.0, player.maxHP);

          await isar.players.put(player);
        }
      }

      await isar.habits.put(habit);
    });
  }

  Future<void> deleteHabit(Habit habit) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.habits.delete(habit.id);
    });
  }
}

final habitControllerProvider = AsyncNotifierProvider<HabitController, void>(
  () {
    return HabitController();
  },
);
