import 'package:firebase_core/firebase_core.dart';
import 'package:game_task/terafas.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'user_service.dart';
import 'theme_loader.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final userId = await getOrCreateUserId();
  final themeData = await carregarTemaDoUsuario(userId);

  ThemeController.init(themeData);
  runApp(MyApp(userId: userId, themeData: themeData));
}

class MyApp extends StatelessWidget {
  final String userId;
  final ThemeData themeData;

  const MyApp({required this.userId, required this.themeData, super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, theme, _) {
        return MaterialApp(
          title: "Game task",
          theme: theme,
          home: TarefasPage(),
        );
      },
    );
  }
}
