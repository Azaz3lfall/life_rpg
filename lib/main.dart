import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/models.dart';
import 'screens/dashboard_screen.dart';

// 1. Criamos uma variável global ou um Provider para o Isar.
// Usar um Provider sobrescrevível no main é uma prática sólida.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar não foi inicializado ainda.');
});

void main() async {
  // Garante que a engine do Flutter esteja pronta antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Descobre onde salvar o banco de dados no dispositivo (Android/iOS)
  final dir = await getApplicationDocumentsDirectory();

  // 3. Abre o banco de dados com os schemas definidos
  final isar = await Isar.open(
    [PlayerSchema, MissionSchema, HabitSchema, RewardSchema],
    directory: dir.path,
    inspector: true, // Permite ver o DB em tempo real no PC (ótimo para debug)
  );

  // 4. Inicializa o app envolvendo-o no ProviderScope do Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Injetamos a instância do Isar que acabamos de abrir
        isarProvider.overrideWithValue(isar),
      ],
      child: const LifeRpgApp(),
    ),
  );
}

class LifeRpgApp extends StatelessWidget {
  const LifeRpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life RPG',
      debugShowCheckedModeBanner: false,
      // Tema Gamer Dark (Como sugerido no plano)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Preto fosco
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC), // Roxo Neon (XP)
          secondary: Color(0xFFFFD700), // Dourado (Coins)
          error: Color(0xFFCF6679), // Vermelho (Punição)
          surface: Color(0xFF1E1E1E),
        ),
        fontFamily:
            'RobotoMono', // Lembre-se de adicionar a fonte no pubspec.yaml depois
      ),
      home: const DashboardScreen(),
    );
  }
}
