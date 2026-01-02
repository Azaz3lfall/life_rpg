import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';

class AddHabitDialog extends ConsumerStatefulWidget {
  const AddHabitDialog({super.key});

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _titleController = TextEditingController();
  bool _isPositive = true;
  double _difficulty = 1.0; // Multiplier for XP

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Hábito'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título do Hábito',
              hintText: 'Ex: Ler 10 páginas',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              _isPositive
                  ? 'Positivo (Quero fazer)'
                  : 'Negativo (Quero evitar)',
            ),
            subtitle: Text(
              _isPositive ? 'Ganha XP ao completar' : 'Perde XP ao falhar',
            ),
            value: _isPositive,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.red.withOpacity(0.5),
            inactiveThumbColor: Colors.red,
            onChanged: (val) {
              setState(() {
                _isPositive = val;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Dificuldade (Multiplicador de XP)'),
          Slider(
            value: _difficulty,
            min: 0.5,
            max: 2.5,
            divisions: 4,
            label: '${_difficulty}x',
            onChanged: (val) {
              setState(() {
                _difficulty = val;
              });
            },
          ),
          Text(
            'Recompensa: +${(10 * _difficulty).round()} XP\nPenalidade: -${(20 * _difficulty).round()} XP',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              ref
                  .read(habitControllerProvider.notifier)
                  .addHabit(
                    _titleController.text,
                    isPositive: _isPositive,
                    reward: (10 * _difficulty).round(),
                    penalty: (20 * _difficulty).round(),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
