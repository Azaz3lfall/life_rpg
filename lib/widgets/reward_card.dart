import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/reward_provider.dart';

class RewardCard extends ConsumerWidget {
  final Reward reward;

  const RewardCard({super.key, required this.reward});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white10,
      child: ListTile(
        leading: Icon(
          reward.isLootBox ? Icons.card_giftcard : Icons.shopping_bag,
          color: Theme.of(context).colorScheme.secondary,
          size: 32,
        ),
        title: Text(
          reward.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          reward.isLootBox ? 'Loot Box (Aleatório)' : 'Recompensa Direta',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        trailing: ElevatedButton.icon(
          onPressed: () async {
            // Confirm Purchase
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirmar Compra'),
                content: Text(
                  'Deseja gastar ${reward.cost} coins em "${reward.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Não'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sim'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              final result = await ref
                  .read(rewardControllerProvider.notifier)
                  .purchaseReward(reward);

              if (context.mounted && result != null) {
                // Determine if success or failure based on string content for SnackBar color
                // Simple heuristic: if starts with "Erro" or "Saldo" -> error
                final isError =
                    result.startsWith('Erro') || result.startsWith('Saldo');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                    backgroundColor: isError
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.monetization_on, size: 16),
          label: Text('${reward.cost}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.withOpacity(0.2),
            foregroundColor: Colors.amber,
          ),
        ),
      ),
    );
  }
}
