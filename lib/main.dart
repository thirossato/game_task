
import 'package:firebase_core/firebase_core.dart';
import 'package:game_task/terafas.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'user_service.dart';
import 'theme_loader.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
    final userId = await getOrCreateUserId();
    final themeData = await carregarTemaDoUsuario(userId);
  runApp(MyApp(userId: userId, themeData: themeData));
  
}

class MyApp extends StatelessWidget {
  final String userId;
  final ThemeData themeData;
  const MyApp({required this.userId, required this.themeData, Key? key}): super(key: key);
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Game task",
      theme: themeData,
      debugShowCheckedModeBanner: false,
      home: TarefasPage(),
    );
  }
}

