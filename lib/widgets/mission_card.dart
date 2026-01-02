import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/mission_provider.dart';

class MissionCard extends ConsumerWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color typeColor;
    int reward;

    switch (mission.type) {
      case MissionType.Main:
        typeColor = Colors.amber; // Gold
        reward = 25;
        break;
      case MissionType.Secondary:
        typeColor = Colors.blueAccent;
        reward = 15;
        break;
      case MissionType.Bonus:
        typeColor = Colors.purpleAccent;
        reward = 10;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white10,
      child: ListTile(
        leading: Icon(
          Icons.star,
          color: mission.isCompleted ? Colors.grey : typeColor,
        ),
        title: Text(
          mission.title,
          style: TextStyle(
            decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
            color: mission.isCompleted ? Colors.grey : Colors.white,
          ),
        ),
        subtitle: Text(
          '${mission.type.name} - ${reward} Coins',
          style: TextStyle(
            color: mission.isCompleted ? Colors.grey : Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: Checkbox(
          value: mission.isCompleted,
          activeColor: typeColor,
          onChanged: (bool? value) {
            ref.read(missionControllerProvider.notifier).toggleMission(mission);
          },
        ),
      ),
    );
  }
}
