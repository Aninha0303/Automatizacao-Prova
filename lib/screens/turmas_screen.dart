import 'package:flutter/material.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Cadastro de turmas e disciplinas (requisito 3 da N3).
class TurmasScreen extends StatelessWidget {
  const TurmasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Turma>>(
      stream: FirestoreService.instance.turmasStream(),
      builder: (context, snapTurmas) {
        final turmas = snapTurmas.data ?? [];
        return StreamBuilder<List<Aluno>>(
          stream: FirestoreService.instance.alunosStream(),
          builder: (context, snapAlunos) {
            final alunos = snapAlunos.data ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: 'Turmas e disciplinas',
                  description:
                      'Turmas salvas no Firebase. Cada turma recebe as suas provas e as suas folhas.',
                  action: FilledButton.icon(
                    onPressed: () => _abrirFormulario(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nova turma'),
                  ),
                ),
                if (turmas.isEmpty)
                  SectionCard(
                    child: Text(
                      snapTurmas.connectionState == ConnectionState.waiting
                          ? 'Carregando turmas…'
                          : 'Nenhuma turma ainda. Toque em "Nova turma" para '
                              'criar a primeira.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ...turmas.map((t) {
                  final qtd =
                      alunos.where((a) => a.turmaId == t.id).length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.nome,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 4),
                                Text(t.disciplina,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ),
                          StatusBadge('$qtd alunos', color: AppColors.muted),
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () =>
                                _abrirFormulario(context, turma: t),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _excluir(context, t),
                          ),
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

  Future<void> _excluir(BuildContext context, Turma t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir turma'),
        content: Text('Excluir "${t.nome}"? Os alunos ficam sem turma.'),
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
      await FirestoreService.instance.deleteTurma(t.id);
      if (context.mounted) toast(context, 'Turma excluída.');
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {Turma? turma}) async {
    final nome = TextEditingController(text: turma?.nome ?? '');
    final disciplina = TextEditingController(text: turma?.disciplina ?? '');
    final formKey = GlobalKey<FormState>();
    String? obrigatorio(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(turma == null ? 'Nova turma' : 'Editar turma'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nome,
                decoration: const InputDecoration(
                    labelText: 'Nome da turma',
                    hintText: 'Ex.: 3º A — Manhã'),
                validator: obrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: disciplina,
                decoration: const InputDecoration(
                    labelText: 'Disciplina',
                    hintText: 'Ex.: Física'),
                validator: obrigatorio,
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
              child: const Text('Salvar')),
        ],
      ),
    );

    if (salvar != true) return;
    final s = FirestoreService.instance;
    if (turma == null) {
      await s.addTurma(nome.text, disciplina.text);
    } else {
      await s.updateTurma(turma.id, nome.text, disciplina.text);
    }
    if (context.mounted) {
      toast(context,
          turma == null ? 'Turma cadastrada.' : 'Turma atualizada.');
    }
  }
}
