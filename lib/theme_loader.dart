import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme_factory.dart';

Future<ThemeData> carregarTemaDoUsuario(String userId) async {
  final userDoc =
  await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final temaSelecionado = userDoc.data()?['temaSelecionado'];

  ThemeData tema;

  return getThemeDataFromId(temaSelecionado);
}
