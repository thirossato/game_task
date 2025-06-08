import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getOrCreateUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  if (userId == null) {
    userId = 'user_1'; // ou Uuid().v4(), se quiser múltiplos usuários
    await prefs.setString('userId', userId);

    // Cria o documento inicial do usuário
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'points': 0,
      'temasDesbloqueados': [],
      'temaSelecionado': null,
    });
  }

  return userId;
}
