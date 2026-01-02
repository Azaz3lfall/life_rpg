import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/player_provider.dart';
import '../providers/mission_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/reward_provider.dart';
import '../screens/add_mission_dialog.dart';
import '../screens/add_habit_dialog.dart';
import '../screens/add_reward_dialog.dart';
import '../widgets/mission_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/reward_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerControllerProvider.notifier).initPlayer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerStreamProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Character Sheet'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'MISSÕES', icon: Icon(Icons.check_circle_outline)),
              Tab(text: 'HÁBITOS', icon: Icon(Icons.repeat)),
              Tab(text: 'LOJA', icon: Icon(Icons.shopping_bag)),
            ],
          ),
        ),
        body: playerAsync.when(
          data: (player) {
            if (player == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                const SizedBox(height: 16),
                // --- PLAYER STATS HEADER ---
                Text(
                  'Nível ${player.currentLevel}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().scale(),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (player.currentHP < 50)
                          ? Colors.redAccent.withOpacity(0.8)
                          : Colors.white10,
                      width: (player.currentHP < 50) ? 2.0 : 1.0,
                    ),
                    boxShadow: (player.currentHP < 50)
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${player.coins} Coins',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- HP BAR ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vitalidade: ${(player.currentHP.isFinite) ? player.currentHP.toInt() : 0} / ${player.maxHP <= 0 ? 100 : player.maxHP.toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 250,
                        child: LinearProgressIndicator(
                          value: (player.maxHP <= 0)
                              ? 0
                              : (player.currentHP / player.maxHP).clamp(
                                  0.0,
                                  1.0,
                                ),
                          backgroundColor: Colors.grey[800],
                          color: Colors.redAccent,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- XP BAR ---
                      Text('XP: ${player.currentXP} / ${player.xpToNextLevel}'),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: (player.xpToNextLevel <= 0)
                              ? 0
                              : (player.currentXP / player.xpToNextLevel).clamp(
                                  0.0,
                                  1.0,
                                ),
                          backgroundColor: Colors.grey[800],
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- TABS CONTENT ---
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: MISSIONS
                      Consumer(
                        builder: (context, ref, child) {
                          final missionsAsync = ref.watch(
                            missionsStreamProvider,
                          );
                          return missionsAsync.when(
                            data: (missions) {
                              if (missions.isEmpty) {
                                return const Center(
                                  child: Text('Nenhuma missão hoje.'),
                                );
                              }
                              return ListView.builder(
                                itemCount: missions.length,
                                itemBuilder: (ctx, i) =>
                                    MissionCard(mission: missions[i]),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, s) => Center(child: Text('Erro: $e')),
                          );
                        },
                      ),

                      // TAB 2: HABITS
                      Consumer(
                        builder: (context, ref, child) {
                          final habitsAsync = ref.watch(habitsStreamProvider);
                          return habitsAsync.when(
                            data: (habits) {
                              if (habits.isEmpty) {
                                return const Center(
                                  child: Text('Nenhum hábito rastreado.'),
                                );
                              }
                              return ListView.builder(
                                itemCount: habits.length,
                                itemBuilder: (ctx, i) =>
                                    HabitCard(habit: habits[i]),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, s) => Center(child: Text('Erro: $e')),
                          );
                        },
                      ),

                      // TAB 3: SHOP (REWARDS)
                      Consumer(
                        builder: (context, ref, child) {
                          final rewardsAsync = ref.watch(rewardsStreamProvider);
                          return rewardsAsync.when(
                            data: (rewards) {
                              if (rewards.isEmpty) {
                                return const Center(
                                  child: Text('A loja está vazia.'),
                                );
                              }
                              return ListView.builder(
                                itemCount: rewards.length,
                                itemBuilder: (ctx, i) =>
                                    RewardCard(reward: rewards[i]),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, s) => Center(child: Text('Erro: $e')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erro: $err')),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              // Check current tab to decide which dialog to show
              final tabIndex = DefaultTabController.of(context).index;
              if (tabIndex == 0) {
                showDialog(
                  context: context,
                  builder: (_) => const AddMissionDialog(),
                );
              } else if (tabIndex == 1) {
                showDialog(
                  context: context,
                  builder: (_) => const AddHabitDialog(),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const AddRewardDialog(),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
