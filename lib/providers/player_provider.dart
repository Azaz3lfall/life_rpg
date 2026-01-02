import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/models.dart';

// Provides the current player from the database
final playerStreamProvider = StreamProvider<Player?>((ref) async* {
  final isar = ref.watch(isarProvider);
  // Watch the first player found (should be only one)
  yield* isar.players.where().watch(fireImmediately: true).map((events) {
    if (events.isEmpty) return null;
    return events.first;
  });
});

class PlayerNotifier extends StateNotifier<AsyncValue<void>> {
  final Isar isar;

  PlayerNotifier(this.isar) : super(const AsyncData(null));

  // Initialize/Check player
  Future<void> initPlayer() async {
    final count = await isar.players.count();
    if (count == 0) {
      final newPlayer = Player()
        ..currentLevel = 1
        ..currentXP = 0
        ..coins = 0
        ..currentHP = 100.0
        ..maxHP = 100.0;

      await isar.writeTxn(() async {
        await isar.players.put(newPlayer);
      });

      // Seed Habits
      await seedVitalityHabits(isar);
    } else {
      // MIGRATION: Fix existing players with 0 HP
      final player = await isar.players.where().findFirst();
      if (player != null && player.maxHP <= 0.1) {
        await isar.writeTxn(() async {
          player.maxHP = 100.0;
          player.currentHP = 100.0;
          await isar.players.put(player);
        });
        // Also ensure habits are seeded for existing users
        await seedVitalityHabits(isar);
      }
    }
  }

  Future<void> addXP(double amount) async {
    final player = await isar.players.where().findFirst();
    if (player != null) {
      await isar.writeTxn(() async {
        player.currentXP += amount;
        // Check level up logic here later
        // if (player.currentXP >= player.xpToNextLevel) ...
        await isar.players.put(player);
      });
    }
  }

  Future<void> removeXP(double amount) async {
    final player = await isar.players.where().findFirst();
    if (player != null) {
      await isar.writeTxn(() async {
        player.currentXP = (player.currentXP - amount).clamp(
          0.0,
          double.infinity,
        );
        await isar.players.put(player);
      });
    }
  }

  Future<void> addCoins(int amount) async {
    final player = await isar.players.where().findFirst();
    if (player != null) {
      await isar.writeTxn(() async {
        player.coins += amount;
        await isar.players.put(player);
      });
    }
  }

  // Função para popular o banco se estiver vazio
  Future<void> seedVitalityHabits(Isar isar) async {
    final count = await isar.habits.count();
    if (count > 0) return; // Já tem dados, não faz nada

    final vitalHabits = [
      // 1. O Básico da Sobrevivência
      Habit()
        ..title = "💧 Beber 2L de Água"
        ..xpReward = 15
        ..xpPenalty =
            30 // Punição Dobrada: Se não beber, dor de cabeça na certa
        ..isPositive = true,

      // 2. O Sono Reparador (Crítico para quem tem 5 filhos)
      Habit()
        ..title = "💤 Dormir antes das 23h"
        ..xpReward =
            50 // Recompensa Alta: Isso muda seu dia
        ..xpPenalty =
            100 // Punição Severa: Se dormir tarde, amanhã é lixo
        ..isPositive = true,

      // 3. O Buff de Movimento
      Habit()
        ..title = "🚶 Caminhada/Alongamento (15min)"
        ..xpReward = 20
        ..xpPenalty = 40
        ..isPositive = true,

      // 4. O Veneno (Hábito Negativo para evitar)
      Habit()
        ..title = "🍔 Fast Food / Açúcar Exagerado"
        ..xpReward = 0
        ..xpPenalty =
            60 // Comeu lixo? Perde XP na hora.
        ..isPositive = false,
    ];

    await isar.writeTxn(() async {
      await isar.habits.putAll(vitalHabits);
    });
  }
}

final playerControllerProvider =
    StateNotifierProvider<PlayerNotifier, AsyncValue<void>>((ref) {
      final isar = ref.watch(isarProvider);
      return PlayerNotifier(isar);
    });
