import 'dart:math';

import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'folhas_screen.dart';

class ProvasScreen extends StatelessWidget {
  const ProvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeader(
          title: 'Provas',
          description:
              'Cada prova gera uma variação por aluno: mesmas questões, ordem de questões e alternativas embaralhada.',
          action: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NovaProvaScreen()),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova'),
          ),
        ),
        ...provas.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.titulo,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                        ),
                        StatusBadge(p.status, color: statusColor(p.status)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${nomeTurma(p.turmaId)} · ${p.data}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      StatusBadge('${p.questoes} questões',
                          color: AppColors.muted),
                      StatusBadge('${p.variacoes} variações',
                          color: AppColors.muted),
                      StatusBadge(p.modo, color: AppColors.muted),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              toast(context, 'Exportar PDF (mock).'),
                          icon: const Icon(Icons.picture_as_pdf_outlined,
                              size: 18),
                          label: const Text('PDF'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => FolhasScreen(prova: p)),
                          ),
                          icon: const Icon(Icons.qr_code_2, size: 18),
                          label: const Text('Folhas'),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class NovaProvaScreen extends StatefulWidget {
  const NovaProvaScreen({super.key});
  @override
  State<NovaProvaScreen> createState() => _NovaProvaScreenState();
}

class _NovaProvaScreenState extends State<NovaProvaScreen> {
  final _titulo = TextEditingController(text: 'Avaliação Bimestral');
  String _turmaId = turmas.first.id;
  final Set<String> _selecionadas =
      questoes.take(4).map((q) => q.id).toSet();
  bool _embQuestoes = true;
  bool _embAlternativas = true;
  bool _individual = true;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  /// Gera as variações embaralhadas localmente (Fisher-Yates via shuffle).
  List<List<Questao>> gerarVariacoes() {
    final base = questoes.where((q) => _selecionadas.contains(q.id)).toList();
    final turma = turmas.firstWhere((t) => t.id == _turmaId);
    final qtd = _individual ? turma.alunos : 1;
    final rnd = Random();
    return List.generate(qtd, (_) {
      final copia = [...base];
      if (_embQuestoes) copia.shuffle(rnd);
      return copia;
    });
  }

  @override
  Widget build(BuildContext context) {
    final turma = turmas.firstWhere((t) => t.id == _turmaId);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova prova')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Dados da prova',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titulo,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                Text('Turma', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: turmas
                      .map((t) => ChoiceChip(
                            label: Text(t.nome),
                            selected: t.id == _turmaId,
                            onSelected: (_) => setState(() => _turmaId = t.id),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Questões · ${_selecionadas.length} selecionadas',
            child: Column(
              children: questoes.map((q) {
                final ativa = _selecionadas.contains(q.id);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: ativa,
                  onChanged: (_) => setState(() {
                    ativa ? _selecionadas.remove(q.id) : _selecionadas.add(q.id);
                  }),
                  title: Text(q.enunciado, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${q.assunto} · ${q.dificuldade} · gabarito ${q.correta}'),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Embaralhamento',
            child: Column(children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _embQuestoes,
                onChanged: (v) => setState(() => _embQuestoes = v),
                title: const Text('Embaralhar ordem das questões'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _embAlternativas,
                onChanged: (v) => setState(() => _embAlternativas = v),
                title: const Text('Embaralhar alternativas'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _individual,
                onChanged: (v) => setState(() => _individual = v),
                title: const Text('Uma variação por aluno'),
                subtitle: const Text('Folha já sai com nome e QR code do aluno.'),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Resumo',
            child: Column(children: [
              _linha(context, 'Turma', turma.nome),
              _linha(context, 'Alunos', '${turma.alunos}'),
              _linha(context, 'Questões', '${_selecionadas.length}'),
              _linha(context, 'Variações',
                  _individual ? '${turma.alunos}' : '1'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selecionadas.isEmpty
                      ? null
                      : () {
                          final v = gerarVariacoes();
                          toast(context, 'Prova gerada com ${v.length} variação(ões).');
                          Navigator.of(context).pop();
                        },
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Gerar provas'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => FolhasScreen(prova: provas.first)),
                  ),
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: const Text('Só folhas de resposta'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
            Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
