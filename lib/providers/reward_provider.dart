import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../main.dart'; // For isarProvider
import '../models/models.dart';
import 'player_provider.dart';

// Stream provider for watching rewards
final rewardsStreamProvider = StreamProvider<List<Reward>>((ref) async* {
  final isar = ref.watch(isarProvider);

  // Watch all rewards
  final stream = isar.rewards.where().watch(fireImmediately: true);

  await for (final rewards in stream) {
    yield rewards;
  }
});

class RewardController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No state to maintain directly
  }

  Future<void> addReward(
    String title,
    int cost, {
    bool isLootBox = false,
    List<String>? lootBoxItems,
  }) async {
    final isar = ref.read(isarProvider);

    final newReward = Reward()
      ..title = title
      ..cost = cost
      ..isLootBox = isLootBox
      ..lootBoxItems = lootBoxItems;

    await isar.writeTxn(() async {
      await isar.rewards.put(newReward);
    });
  }

  // Returns a message about the purchase (e.g., item obtained) or null if failed
  Future<String?> purchaseReward(Reward reward) async {
    final isar = ref.read(isarProvider);
    // final playerController = ref.read(playerControllerProvider.notifier); // Unused currently

    // Check if player has enough coins
    final player = await isar.players.where().findFirst();
    if (player == null) return "Erro: Jogador não encontrado";

    if (player.coins < reward.cost) {
      return "Saldo insuficiente! Você precisa de ${reward.cost} coins.";
    }

    // Deduct coins
    await isar.writeTxn(() async {
      player.coins -= reward.cost;
      await isar.players.put(player);
    });

    // Determine result
    if (reward.isLootBox && (reward.lootBoxItems?.isNotEmpty ?? false)) {
      // Pick random item
      final items = reward.lootBoxItems!;
      final randomItem = (items..shuffle()).first;
      return "Loot Box aberta! Você ganhou: $randomItem";
    } else {
      return "Comprado: ${reward.title}";
    }
  }

  Future<void> deleteReward(Reward reward) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.rewards.delete(reward.id);
    });
  }
}

final rewardControllerProvider = AsyncNotifierProvider<RewardController, void>(
  () {
    return RewardController();
  },
);
