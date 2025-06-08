import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tema {
  final String id;
  final String temaId;
  final String nome;
  final Color cor;
  final num pontos;

  Tema({required this.id, required this.temaId, required this.nome, required this.cor, required this.pontos});

  factory Tema.fromMap(Map<String, dynamic> data, String docId) {
    return Tema(
      id: docId,
      temaId: data['temaId'] ?? '',
      nome: data['nome'] ?? '',
      cor: Color(int.parse(data['corHex'], radix: 16)).withOpacity(1.0),
      pontos: data['pontos'] ?? 100
    );
  }
}

class TemaSelectionScreen extends StatefulWidget {
  final String userId;

  const TemaSelectionScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _TemaSelectionScreenState createState() => _TemaSelectionScreenState();
}

class _TemaSelectionScreenState extends State<TemaSelectionScreen> {
  late Future<List<Tema>> _temasFuture;
  late Future<List<String>> _desbloqueadosFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _temasFuture = _getTemasDisponiveis();
    _desbloqueadosFuture = _getTemasDesbloqueados();
  }

  Future<List<String>> _getTemasDesbloqueados() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final list = doc.data()?['temasDesbloqueados'] ?? [];
    return List<String>.from(list);
  }

  Future<List<Tema>> _getTemasDisponiveis() async {
    final snapshot = await FirebaseFirestore.instance.collection('temas').get();
    return snapshot.docs.map((doc) => Tema.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecione um Tema')),
      body: FutureBuilder(
        future: Future.wait([_temasFuture, _desbloqueadosFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final List<Tema> temas = snapshot.data![0];
          final List<String> desbloqueados = snapshot.data![1];

          return ListView.builder(
            itemCount: temas.length,
            itemBuilder: (context, index) {
              final tema = temas[index];
              final desbloqueado = desbloqueados.contains(tema.temaId);

              return Card(
                color: tema.cor.withOpacity(0.2),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: tema.cor),
                  title: Text(tema.nome),
                  trailing: desbloqueado
                      ? null
                      : Icon(Icons.lock, color: Colors.amber),
                  onTap: () {
                    if (!desbloqueado) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Tema bloqueado"),
                            content: Text(
                              "Este tema está bloqueado. Deseja desbloqueá-lo por ${tema.pontos} pontos?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();

                                  final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
                                  final userDoc = await userRef.get();
                                  final pontos = userDoc.data()?['points'] ?? 0;

                                  if (pontos >= tema.pontos) {
                                    await userRef.update({
                                      'points': FieldValue.increment(-tema.pontos),
                                      'temasDesbloqueados': FieldValue.arrayUnion([tema.temaId]),
                                    });

                                    setState(() {
                                      _carregarDados();
                                    });

                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Tema "${tema.nome}" desbloqueado!')),
                                      );
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Você não tem pontos suficientes.')),
                                    );
                                  }
                                },
                                child: Text("Desbloquear"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // futura lógica para aplicar o tema desbloqueado
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}