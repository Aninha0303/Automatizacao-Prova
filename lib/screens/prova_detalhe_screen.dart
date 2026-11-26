import 'package:flutter/material.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Visualiza e edita uma prova já salva (requisito 6):
/// mostra as variações geradas, o gabarito de cada uma e permite
/// alterar título, data e status.
class ProvaDetalheScreen extends StatefulWidget {
  final String provaId;
  const ProvaDetalheScreen({super.key, required this.provaId});
  @override
  State<ProvaDetalheScreen> createState() => _ProvaDetalheScreenState();
}

class _ProvaDetalheScreenState extends State<ProvaDetalheScreen> {
  static const _ordemStatus = ['Rascunho', 'Pronta', 'Aplicada', 'Corrigida'];

  Future<void> _editar(Prova p) async {
    final titulo = TextEditingController(text: p.titulo);
    final data = TextEditingController(text: p.data);
    final formKey = GlobalKey<FormState>();
    String? obrigatorio(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Editar prova'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: obrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: data,
                decoration: const InputDecoration(labelText: 'Data'),
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
    await FirestoreService.instance
        .updateProva(p.copyWith(
            titulo: titulo.text.trim(), data: data.text.trim()));
    if (mounted) toast(context, 'Prova atualizada.');
  }

  Future<void> _mudarStatus(Prova p, String novo) async {
    await FirestoreService.instance.updateProva(p.copyWith(status: novo));
    if (mounted) toast(context, 'Status: $novo.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prova')),
      body: StreamBuilder<List<Prova>>(
        stream: FirestoreService.instance.provasStream(),
        builder: (context, snap) {
          final todas = snap.data ?? [];
          final matching = todas.where((p) => p.id == widget.provaId);
          if (matching.isEmpty) {
            return Center(
              child: Text(
                snap.connectionState == ConnectionState.waiting
                    ? 'Carregando prova…'
                    : 'Prova não encontrada.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          final p = matching.first;
          return StreamBuilder<List<Turma>>(
            stream: FirestoreService.instance.turmasStream(),
            builder: (context, snapTurmas) {
              final turmas = snapTurmas.data ?? [];
              final t = turmas.where((x) => x.id == p.turmaId);
              final turmaNome = t.isEmpty ? '—' : t.first.nome;
              final disciplina = t.isEmpty ? '' : t.first.disciplina;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PageHeader(
                    title: p.titulo,
                    description:
                        '$turmaNome${disciplina.isEmpty ? '' : ' · $disciplina'} · ${p.data}',
                    action: OutlinedButton.icon(
                      onPressed: () => _editar(p),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                  ),
                  SectionCard(
                    title: 'Situação',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          StatusBadge(p.status, color: statusColor(p.status)),
                          StatusBadge('${p.questoes} questões',
                              color: AppColors.muted),
                          StatusBadge('${p.variacoes} variações',
                              color: AppColors.muted),
                          StatusBadge(
                              'corrigidas ${p.corrigidas}/${p.total}',
                              color: AppColors.muted),
                        ]),
                        const SizedBox(height: 8),
                        Text(p.modo,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, children: [
                          for (final s in _ordemStatus)
                            if (s != p.status)
                              OutlinedButton(
                                onPressed: () => _mudarStatus(p, s),
                                child: Text('Marcar como $s'),
                              ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Variações geradas',
                    child: p.variacoesDados.isEmpty
                        ? Text(
                            'Nenhuma variação salva. Gere a prova de novo '
                            'para criar as variações.',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : Column(
                            children: p.variacoesDados
                                .map((v) => ExpansionTile(
                                      tilePadding: EdgeInsets.zero,
                                      title: Text(
                                          '${v.id} · ${v.questoes.length} questões'),
                                      subtitle: Text(
                                          'gabarito: ${v.questoes.map((q) => q.correta).join(' ')}'),
                                      children: [
                                        ...v.questoes
                                            .asMap()
                                            .entries
                                            .map((e) => ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Text(
                                                      'Questão ${e.value.questaoId}'),
                                                  subtitle: Text(
                                                      'alternativas: ${e.value.alternativas.map((a) => a.letra).join(' ')}'),
                                                  trailing: StatusBadge(
                                                      'gabarito ${e.value.correta}',
                                                      color:
                                                          AppColors.success),
                                                )),
                                      ],
                                    ))
                                .toList(),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
