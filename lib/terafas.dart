import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class TarefasPage extends StatelessWidget {
  final TextEditingController _tituloController = TextEditingController();

  TarefasPage({super.key});

  void _adicionarTarefa(BuildContext context) {
    String prioridadeSelecionada = 'Média';
    final List<String> prioridades = ['Baixa', 'Média', 'Alta'];
    DateTime? dataSelecionada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Nova Tarefa"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(labelText: "Título da Tarefa"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: prioridadeSelecionada,
                    decoration: InputDecoration(labelText: "Prioridade"),
                    items:
                        prioridades.map((String prioridade) {
                          return DropdownMenuItem<String>(
                            value: prioridade,
                            child: Text(prioridade),
                          );
                        }).toList(),
                    onChanged: (String? novaPrioridade) {
                      setState(() {
                        prioridadeSelecionada = novaPrioridade!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        dataSelecionada == null
                            ? "Data de Vencimento"
                            : "Vence em: ${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}",
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (data != null) {
                            setState(() {
                              dataSelecionada = data;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    if (_tituloController.text.isNotEmpty &&
                        dataSelecionada != null) {
                      FirebaseFirestore.instance.collection('tarefas').add({
                        'Titulo': _tituloController.text,
                        'Status': 'pendente',
                        'Prioridade': prioridadeSelecionada,
                        'Data_vencimento': Timestamp.fromDate(dataSelecionada!),
                      });
                      _tituloController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Adicionar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deletarTarefa(String id) {
    FirebaseFirestore.instance.collection('tarefas').doc(id).delete();
  }

  void _editarTarefa(
    BuildContext context,
    String id,
    String tituloAtual,
    String prioridadeAtual,
    Timestamp dataAtual,
  ) {
    _tituloController.text = tituloAtual;
    String prioridadeSelecionada = prioridadeAtual;
    DateTime? dataSelecionada = dataAtual.toDate();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Editar Tarefa"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(labelText: "Título da Tarefa"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: prioridadeSelecionada,
                    decoration: InputDecoration(labelText: "Prioridade"),
                    items:
                        ['Baixa', 'Média', 'Alta'].map((String prioridade) {
                          return DropdownMenuItem<String>(
                            value: prioridade,
                            child: Text(prioridade),
                          );
                        }).toList(),
                    onChanged: (String? novaPrioridade) {
                      setState(() {
                        prioridadeSelecionada = novaPrioridade!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        dataSelecionada == null
                            ? "Data de Vencimento"
                            : "Vence em: ${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}",
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (data != null) {
                            setState(() {
                              dataSelecionada = data;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    if (_tituloController.text.isNotEmpty &&
                        dataSelecionada != null) {
                      FirebaseFirestore.instance
                          .collection('tarefas')
                          .doc(id)
                          .update({
                            'Titulo': _tituloController.text,
                            'Prioridade': prioridadeSelecionada,
                            'Data_vencimento': Timestamp.fromDate(
                              dataSelecionada!,
                            ),
                          });
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPrioridadeChip(String prioridade) {
    Color cor;
    IconData icone;

    switch (prioridade) {
      case 'Alta':
        cor = Colors.red;
        icone = Icons.priority_high;
        break;
      case 'Média':
        cor = Colors.orange;
        icone = Icons.warning;
        break;
      case 'Baixa':
      default:
        cor = Colors.green;
        icone = Icons.low_priority;
        break;
    }

    return Chip(
      avatar: Icon(icone, color: Colors.white, size: 16),
      label: Text(prioridade, style: TextStyle(color: Colors.white)),
      backgroundColor: cor,
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'pendente':
        return Colors.grey;
      case 'em progresso':
        return Colors.green;
      case 'paralisada':
        return Colors.orange;
      case 'concluída':
        return Colors.blueAccent;
      default:
        return Colors.black;
    }
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

          // Agrupamento e ordenação
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(Duration(days: 1));
          final weekStart = DateTime(
            today.year,
            today.month,
            today.day - today.weekday % 7,
          );
          final endOfWeek = DateTime(
            today.year,
            today.month,
            today.day + 7 - today.weekday % 7,
          );
          final categories = {
            "Concluídas": [],
            "Vencidas": <QueryDocumentSnapshot>[],
            "Vencendo hoje": [],
            "Vencendo amanhã": [],
            "Vencendo esta semana": [],
            "Vencendo semana que vem": [],
            "Vencendo futuramente": [],
          };

          for (var doc in snapshot.data!.docs) {
            final Timestamp timestamp = doc['Data_vencimento'];
            final DateTime dueDate = timestamp.toDate();
            final date = DateTime(dueDate.year, dueDate.month, dueDate.day);
            final bool concluida = doc['Status'] == 'concluída';

            if (concluida) {
              categories["Concluídas"]!.add(doc);
              continue;
            }

            if (date.isBefore(today)) {
              categories["Vencidas"]!.add(doc);
            } else if (date.isAtSameMomentAs(today)) {
              categories["Vencendo hoje"]!.add(doc);
            } else if (date.isAtSameMomentAs(tomorrow)) {
              categories["Vencendo amanhã"]!.add(doc);
            } else if (date.isAfter(weekStart) && date.isBefore(endOfWeek) ||
                date.isAtSameMomentAs(endOfWeek)) {
              categories["Vencendo esta semana"]!.add(doc);
            } else if (date.isAfter(endOfWeek) &&
                    date.isBefore(
                      endOfWeek.add(
                        Duration(
                          days: DateTime.daysPerWeek - endOfWeek.weekday + 7,
                        ),
                      ),
                    ) ||
                date.isAtSameMomentAs(
                  endOfWeek.add(
                    Duration(
                      days: DateTime.daysPerWeek - endOfWeek.weekday + 7,
                    ),
                  ),
                )) {
              categories["Vencendo semana que vem"]!.add(doc);
            } else {
              categories["Vencendo futuramente"]!.add(doc);
            }
          }

          // Ordem de prioridade
          final prioridadeOrder = {'Alta': 0, 'Média': 1, 'Baixa': 2};

          return ListView(
            children:
                categories.entries.map((entry) {
                  final tarefas = entry.value;
                  tarefas.sort((a, b) {
                    final prioridadeA = prioridadeOrder[a['Prioridade']] ?? 3;
                    final prioridadeB = prioridadeOrder[b['Prioridade']] ?? 3;
                    return prioridadeA.compareTo(prioridadeB);
                  });

                  if (tarefas.isEmpty)
                    return SizedBox(); // Oculta categorias vazias

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...tarefas.map((doc) {
                        final bool concluida = doc['Status'] == 'concluída';
                        return Opacity(
                          opacity: concluida ? 0.5 : 1.0,
                          child: ListTile(
                            title: Text(
                              doc['Titulo'],
                              style: TextStyle(
                                decoration:
                                    concluida
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Chip(
                                  label: Text(
                                    doc['Status'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _corStatus(doc['Status']),
                                ),
                                SizedBox(width: 8),
                                _buildPrioridadeChip(doc['Prioridade']),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                if(!concluida) ...[IconButton(
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: Colors.green,
                                  ),
                                  tooltip: 'Em progresso',
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('tarefas')
                                        .doc(doc.id)
                                        .update({'Status': 'em progresso'});
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.pause, color: Colors.orange),
                                  tooltip: 'Paralisada',
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('tarefas')
                                        .doc(doc.id)
                                        .update({'Status': 'paralisada'});
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.blueAccent,
                                  ),
                                  tooltip: 'Concluir',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            title: Text("Concluir Tarefa"),
                                            content: Text(
                                              "Tem certeza que deseja marcar esta tarefa como concluída?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(ctx),
                                                child: Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('tarefas')
                                                      .doc(doc.id)
                                                      .update({
                                                        'Status': 'concluída',
                                                      });
                                                  Navigator.pop(ctx);
                                                },
                                                child: Text("Sim"),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                                ],
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  tooltip:
                                      doc['Status'] == 'concluída'
                                          ? 'Tarefa concluída (bloqueada)'
                                          : 'Editar',
                                  onPressed:
                                      doc['Status'] == 'concluída'
                                          ? null
                                          : () => _editarTarefa(
                                            context,
                                            doc.id,
                                            doc['Titulo'],
                                            doc['Prioridade'],
                                            doc['Data_vencimento'],
                                          ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Deletar',
                                  onPressed: () => _deletarTarefa(doc.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
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
