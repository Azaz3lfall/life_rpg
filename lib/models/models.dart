import 'package:isar/isar.dart';

part 'models.g.dart';

// ==========================================
// A. USER / PLAYER
// ==========================================
@collection
class Player {
  Id id =
      Isar.autoIncrement; // ID único (só teremos 1 player, mas o Isar exige)

  int currentLevel = 1;

  double currentXP = 0.0;

  // Getter calculado: não vai pro banco, é lógica de negócio
  // Ex: Nível 1 precisa de 100XP, Nível 2 precisa de 200XP...
  @ignore
  double get xpToNextLevel => currentLevel * 100.0;

  int coins = 0; // Moedas para gastar na loja

  double currentHP = 100.0;

  double maxHP = 100.0;
}

// ==========================================
// B. MISSION (Missões do Dia)
// ==========================================

enum MissionType {
  Main, // Ouro: 25c
  Secondary, // Ouro: 15c
  Bonus, // Ouro: 10c
}

@collection
class Mission {
  Id id = Isar.autoIncrement;

  late String title;

  @enumerated
  late MissionType type; // Salva como index (0, 1, 2) no banco pra ser rápido

  bool isCompleted = false;

  late DateTime
  date; // Importante para filtrar: "Mostrar missões onde date == hoje"
}

// ==========================================
// C. HABIT (Hábitos Recorrentes)
// ==========================================
@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String title;

  int xpReward = 10; // Padrão: ganha 10 XP

  int xpPenalty = 20; // Padrão: perde 20 XP (O dobro, regra anti-preguiça)

  bool isPositive =
      true; // True = Quero fazer (beber água); False = Quero evitar (fumar)

  int currentStreak = 0; // Dias seguidos fazendo

  // Data da última vez que foi completado (para calcular o streak)
  DateTime? lastCompletedDate;
}

// ==========================================
// D. REWARD (Loja & Loot Boxes)
// ==========================================
@collection
class Reward {
  Id id = Isar.autoIncrement;

  late String title;

  int cost = 50;

  bool isLootBox = false; // Se true, é sorteio

  List<String>? lootBoxItems; // Itens possíveis dentro da caixa
}
