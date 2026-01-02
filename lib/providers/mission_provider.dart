import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/models.dart';

// Stream of missions for the specified date (defaults to today if not filtered, but let's assume all for now or filter by date)
// For MVP Phase 1/2, let's just show all missions for today.
final missionsStreamProvider = StreamProvider<List<Mission>>((ref) async* {
  final isar = ref.watch(isarProvider);

  // Calculate start and end of today
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  yield* isar.missions
      .filter()
      .dateBetween(
        startOfDay,
        endOfDay,
      ) // This assumes 'date' is stored as DateTime
      .watch(fireImmediately: true);
});

class MissionNotifier extends StateNotifier<AsyncValue<void>> {
  final Isar isar;

  MissionNotifier(this.isar) : super(const AsyncData(null));

  Future<void> addMission(String title, MissionType type) async {
    final newMission = Mission()
      ..title = title
      ..type = type
      ..date = DateTime.now()
      ..isCompleted = false;

    await isar.writeTxn(() async {
      await isar.missions.put(newMission);
    });
  }

  Future<void> toggleMission(Mission mission) async {
    await isar.writeTxn(() async {
      final wasCompleted = mission.isCompleted;
      mission.isCompleted = !mission.isCompleted;

      // If we are marking it as completed (it was false, now true)
      if (!wasCompleted && mission.isCompleted) {
        final player = await isar.players.where().findFirst();

        if (player != null) {
          int coinsReward = 0;
          double xpReward = 0.0;

          switch (mission.type) {
            case MissionType.Main:
              coinsReward = 25;
              xpReward = 50.0;
              break;
            case MissionType.Secondary:
              coinsReward = 15;
              xpReward = 30.0;
              break;
            case MissionType.Bonus:
              coinsReward = 10;
              xpReward = 10.0;
              break;
          }

          player.coins += coinsReward;
          player.currentXP += xpReward;
          await isar.players.put(player);
        }
      }
      // Optional: Handle removing rewards if untoggled?
      // For now, let's keep it simple and just reward on completion.
      // Preventing abuse can be done by checking if completion date is already set, etc.

      await isar.missions.put(mission);
    });
  }
}

final missionControllerProvider =
    StateNotifierProvider<MissionNotifier, AsyncValue<void>>((ref) {
      final isar = ref.watch(isarProvider);
      return MissionNotifier(isar);
    });
