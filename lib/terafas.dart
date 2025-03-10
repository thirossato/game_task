import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TarefasPage extends StatelessWidget {
  final TextEditingController _tituloController = TextEditingController();

  TarefasPage({super.key});

  void _adicionarTarefa(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Nova Tarefa"),
            content: TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: "Título da Tarefa"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Fecha o diálogo
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  if (_tituloController.text.isNotEmpty) {
                    FirebaseFirestore.instance.collection('tarefas').add({
                      'Titulo': _tituloController.text,
                      'Status': 'pendente', // Status inicial
                      'Data_vencimento': Timestamp.now(),
                    });
                    _tituloController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text("Adicionar"),
              ),
            ],
          ),
    );
  }

  void _deletarTarefa(String id) {
    FirebaseFirestore.instance.collection('tarefas').doc(id).delete();
  }

  void _editarTarefa(BuildContext context, String id, String tituloAtual) {
  TextEditingController _tituloController = TextEditingController(text: tituloAtual);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Editar Tarefa"),
      content: TextField(
        controller: _tituloController,
        decoration: InputDecoration(labelText: "Novo título"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Fecha o diálogo
          child: Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            if (_tituloController.text.isNotEmpty) {
              FirebaseFirestore.instance.collection('tarefas').doc(id).update({
                'Titulo': _tituloController.text,
              });
              Navigator.pop(context);
            }
          },
          child: Text("Salvar"),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Tarefas")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tarefas').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return ListView(
            children:
                snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['Titulo']),
                    subtitle: Text("Status: ${doc['Status']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              () =>
                                  _editarTarefa(context, doc.id, doc['Titulo']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletarTarefa(doc.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarTarefa(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
