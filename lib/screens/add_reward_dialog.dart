import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reward_provider.dart';

class AddRewardDialog extends ConsumerStatefulWidget {
  const AddRewardDialog({super.key});

  @override
  ConsumerState<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends ConsumerState<AddRewardDialog> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController(text: '50');
  bool _isLootBox = false;
  final _lootItemsController = TextEditingController(); // Comma separated

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Item da Loja'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nome do Item / Caixa',
                hintText: 'Ex: Ingresso Cinema',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Custo (Coins)',
                suffixText: 'Coins',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('É uma Loot Box?'),
              subtitle: const Text('Sorteia um item aleatório'),
              value: _isLootBox,
              onChanged: (val) {
                setState(() {
                  _isLootBox = val;
                });
              },
            ),
            if (_isLootBox) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _lootItemsController,
                decoration: const InputDecoration(
                  labelText: 'Itens Possíveis',
                  hintText: 'Separe por vírgula: Item A, Item B, Item C',
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text;
            final cost = int.tryParse(_costController.text) ?? 50;

            if (title.isNotEmpty) {
              List<String>? lootItems;
              if (_isLootBox && _lootItemsController.text.isNotEmpty) {
                lootItems = _lootItemsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
              }

              ref
                  .read(rewardControllerProvider.notifier)
                  .addReward(
                    title,
                    cost,
                    isLootBox: _isLootBox,
                    lootBoxItems: lootItems,
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
