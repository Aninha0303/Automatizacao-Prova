import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

class AlunosScreen extends StatelessWidget {
  const AlunosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Aluno>>(
      stream: FirestoreService.instance.alunosStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Erro ao carregar: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final todos = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageHeader(
              title: 'Turmas e alunos',
              description:
                  'Alunos salvos no Firebase. Toque no lápis para editar ou na lixeira para excluir.',
              action: FilledButton.icon(
                onPressed: () => _abrirFormulario(context),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Novo aluno'),
              ),
            ),
            ...turmas.map((t) {
              final lista = todos.where((a) => a.turmaId == t.id).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SectionCard(
                  title: t.nome,
                  trailing: StatusBadge(
                      '${t.disciplina} · ${lista.length} alunos',
                      color: AppColors.muted),
                  child: Column(
                    children: [
                      if (lista.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Nenhum aluno nesta turma.',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ...lista.map((a) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(a.nome)),
                                Text(a.matricula,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18),
                                  onPressed: () =>
                                      _abrirFormulario(context, aluno: a),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  onPressed: () => _excluir(context, a),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _excluir(BuildContext context, Aluno a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir aluno'),
        content: Text('Excluir ${a.nome}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await FirestoreService.instance.deleteAluno(a.id);
      if (context.mounted) toast(context, 'Aluno excluído.');
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {Aluno? aluno}) async {
    final nome = TextEditingController(text: aluno?.nome ?? '');
    final matricula = TextEditingController(text: aluno?.matricula ?? '');
    var turmaId = aluno?.turmaId ?? turmas.first.id;
    final formKey = GlobalKey<FormState>();

    final salvar = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(aluno == null ? 'Novo aluno' : 'Editar aluno'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: matricula,
                  decoration: const InputDecoration(labelText: 'Matrícula'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe a matrícula'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: turmaId,
                  decoration: const InputDecoration(labelText: 'Turma'),
                  items: turmas
                      .map((t) =>
                          DropdownMenuItem(value: t.id, child: Text(t.nome)))
                      .toList(),
                  onChanged: (v) => setState(() => turmaId = v ?? turmaId),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(c, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (salvar != true) return;
    final s = FirestoreService.instance;
    if (aluno == null) {
      await s.addAluno(nome.text.trim(), matricula.text.trim(), turmaId);
    } else {
      await s.updateAluno(
          aluno.id, nome.text.trim(), matricula.text.trim(), turmaId);
    }
    if (context.mounted) {
      toast(context, aluno == null ? 'Aluno cadastrado.' : 'Aluno atualizado.');
    }
  }
}
