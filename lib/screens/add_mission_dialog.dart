import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/mission_provider.dart';

class AddMissionDialog extends ConsumerStatefulWidget {
  const AddMissionDialog({super.key});

  @override
  ConsumerState<AddMissionDialog> createState() => _AddMissionDialogState();
}

class _AddMissionDialogState extends ConsumerState<AddMissionDialog> {
  final _titleController = TextEditingController();
  MissionType _selectedType = MissionType.Main;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Missão'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título da Missão',
              hintText: 'Ex: Fazer exercícios',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MissionType>(
            // value: _selectedType, // Remove this if you want to use state variable, but usually value is correct for controlled component.
            // Wait, warning says 'value' is deprecated? No, 'initialValue' is for FormField only if not controlled.
            // Actually, DropdownButtonFormField 'value' is NOT deprecated in recent Flutter.
            // The analyzer said: 'value' is deprecated ... Use initialValue instead.
            // This is strange for a controlled field. But let's follow advice if it's a FormField.
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Tipo de Missão'),
            items: MissionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
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
                  .read(missionControllerProvider.notifier)
                  .addMission(_titleController.text, _selectedType);
              Navigator.pop(context);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
