import 'package:flutter/material.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Cadastro de alunos, agrupados pelas turmas do Firebase.
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
        final todos = snap.data ?? [];
        return StreamBuilder<List<Turma>>(
          stream: FirestoreService.instance.turmasStream(),
          builder: (context, snapTurmas) {
            final turmas = snapTurmas.data ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: 'Alunos',
                  description:
                      'Alunos salvos no Firebase, com matrícula e turma. '
                      'A matrícula é o que liga o QR code da folha ao aluno.',
                  action: FilledButton.icon(
                    onPressed: turmas.isEmpty
                        ? null
                        : () => _abrirFormulario(context, turmas: turmas),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Novo aluno'),
                  ),
                ),
                if (turmas.isEmpty)
                  const SectionCard(
                    child: Text(
                        'Cadastre a turma primeiro, na aba "Turmas", '
                        'para depois adicionar os alunos.'),
                  ),
                ...turmas.map((t) {
                  final lista =
                      todos.where((a) => a.turmaId == t.id).toList();
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
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ),
                          ...lista.map((a) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(a.nome)),
                                    Text(a.matricula,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    IconButton(
                                      tooltip: 'Editar',
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 18),
                                      onPressed: () => _abrirFormulario(context,
                                          turmas: turmas, aluno: a),
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

  Future<void> _abrirFormulario(BuildContext context,
      {required List<Turma> turmas, Aluno? aluno}) async {
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
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o nome'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: matricula,
                  decoration:
                      const InputDecoration(labelText: 'Matrícula'),
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
      await s.addAluno(nome.text, matricula.text, turmaId);
    } else {
      await s.updateAluno(
          aluno.id, nome.text, matricula.text, turmaId);
    }
    if (context.mounted) {
      toast(context,
          aluno == null ? 'Aluno cadastrado.' : 'Aluno atualizado.');
    }
  }
}
