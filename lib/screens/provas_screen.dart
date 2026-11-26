import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'folhas_screen.dart';
import 'prova_detalhe_screen.dart';

/// Lista de provas salvas no Firebase (requisito 6).
class ProvasScreen extends StatelessWidget {
  const ProvasScreen({super.key});

  static const _ordemStatus = ['Rascunho', 'Pronta', 'Aplicada', 'Corrigida'];

  Future<void> _avancarStatus(BuildContext context, Prova p) async {
    final i = _ordemStatus.indexOf(p.status);
    final novo = _ordemStatus[(i + 1) % _ordemStatus.length];
    await FirestoreService.instance.updateProva(p.copyWith(status: novo));
    if (context.mounted) toast(context, 'Status alterado para "$novo".');
  }

  Future<void> _excluir(BuildContext context, Prova p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir prova'),
        content:
            Text('Excluir "${p.titulo}"? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirestoreService.instance.deleteProva(p.id);
      if (context.mounted) toast(context, 'Prova excluída.');
    }
  }

  Future<void> _pdf(BuildContext context, Prova p) async {
    final s = FirestoreService.instance;
    final alunos = await s.alunosStream().first;
    final turmas = await s.turmasStream().first;
    final questoes = await s.questoesStream().first;
    if (!context.mounted) return;

    final daTurma = alunos.where((a) => a.turmaId == p.turmaId).toList();
    if (daTurma.isEmpty) {
      toast(context, 'Nenhum aluno nessa turma.');
      return;
    }
    if (p.variacoesDados.isEmpty) {
      toast(context, 'Essa prova não tem variações salvas.');
      return;
    }
    final matching = turmas.where((t) => t.id == p.turmaId);
    final turmaNome = matching.isEmpty ? 'Turma' : matching.first.nome;
    final banco = {for (final q in questoes) q.id: q};

    try {
      await PdfService.gerarProva(
        prova: p,
        turmaNome: turmaNome,
        alunos: daTurma,
        banco: banco,
      );
    } catch (e) {
      if (context.mounted) toast(context, 'Não foi possível gerar o PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Prova>>(
      stream: FirestoreService.instance.provasStream(),
      builder: (context, snap) {
        final lista = snap.data ?? [];
        return StreamBuilder<List<Turma>>(
          stream: FirestoreService.instance.turmasStream(),
          builder: (context, snapTurmas) {
            final turmas = snapTurmas.data ?? [];
            String nomeTurma(String id) {
              final t = turmas.where((x) => x.id == id);
              return t.isEmpty ? '—' : t.first.nome;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: 'Provas',
                  description:
                      'Provas salvas no Firebase, com as variações já '
                      'embaralhadas e o gabarito de cada uma.',
                  action: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NovaProvaScreen()),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nova'),
                  ),
                ),
                if (lista.isEmpty)
                  SectionCard(
                    child: Text(
                      snap.connectionState == ConnectionState.waiting
                          ? 'Carregando provas…'
                          : 'Nenhuma prova ainda. Toque em "Nova" para criar '
                              'a primeira.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ...lista.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(p.titulo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                                StatusBadge(p.status,
                                    color: statusColor(p.status)),
                                IconButton(
                                  tooltip: 'Avançar status',
                                  onPressed: () => _avancarStatus(context, p),
                                  icon: const Icon(Icons.sync, size: 18),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  onPressed: () => _excluir(context, p),
                                  icon:
                                      const Icon(Icons.delete_outline, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${nomeTurma(p.turmaId)} · ${p.data}',
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              StatusBadge('${p.questoes} questões',
                                  color: AppColors.muted),
                              StatusBadge('${p.variacoes} variações',
                                  color: AppColors.muted),
                              StatusBadge(
                                  'corrigidas ${p.corrigidas}/${p.total}',
                                  color: AppColors.muted),
                            ]),
                            const SizedBox(height: 6),
                            Text(p.modo,
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ProvaDetalheScreen(
                                                provaId: p.id)),
                                  ),
                                  icon: const Icon(Icons.visibility_outlined,
                                      size: 18),
                                  label: const Text('Abrir'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pdf(context, p),
                                  icon: const Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 18),
                                  label: const Text('PDF'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            FolhasScreen(prova: p)),
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
          },
        );
      },
    );
  }
}

/// Cria a prova e grava no Firestore as variações já embaralhadas
/// (questões e alternativas) com o gabarito de cada variação.
class NovaProvaScreen extends StatefulWidget {
  const NovaProvaScreen({super.key});
  @override
  State<NovaProvaScreen> createState() => _NovaProvaScreenState();
}

class _NovaProvaScreenState extends State<NovaProvaScreen> {
  final _titulo = TextEditingController(text: 'Avaliação');
  String? _turmaId;
  final Set<String> _selecionadas = {};
  bool _inicializou = false;
  bool _embQuestoes = true;
  bool _embAlternativas = true;
  bool _individual = true;
  bool _salvando = false;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  /// Embaralha a ordem das questões e a ordem das alternativas,
  /// renumerando as letras e o gabarito de cada variação.
  List<Variacao> gerarVariacoes(List<Questao> banco, int quantidade) {
    final base =
        banco.where((q) => _selecionadas.contains(q.id)).toList();
    final rnd = Random();
    final total = quantidade < 1 ? 1 : quantidade;
    return List.generate(total, (i) {
      final ordem = [...base];
      if (_embQuestoes) ordem.shuffle(rnd);
      final questoes = ordem.map((q) {
        final alts = [...q.alternativas];
        if (_embAlternativas) alts.shuffle(rnd);
        final renumeradas = <Alternativa>[];
        var correta = 'A';
        for (var j = 0; j < alts.length; j++) {
          final letra = String.fromCharCode(65 + j);
          renumeradas.add(Alternativa(letra, alts[j].texto));
          if (alts[j].letra == q.correta) correta = letra;
        }
        return QuestaoProva(
            questaoId: q.id, alternativas: renumeradas, correta: correta);
      }).toList();
      return Variacao(
          id: 'V-${(i + 1).toString().padLeft(2, '0')}', questoes: questoes);
    });
  }

  Prova montarProva(List<Questao> banco, List<Aluno> alunosDaTurma) {
    final quantidade = _individual
        ? (alunosDaTurma.isEmpty ? 1 : alunosDaTurma.length)
        : 1;
    final variacoes = gerarVariacoes(banco, quantidade);
    final hoje = DateTime.now();
    final data =
        '${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';
    final modo = _embQuestoes && _embAlternativas
        ? 'Questões e alternativas embaralhadas'
        : _embQuestoes
            ? 'Só a ordem das questões embaralhada'
            : _embAlternativas
                ? 'Só as alternativas embaralhadas'
                : 'Sem embaralhamento';
    return Prova(
      id: '',
      titulo: _titulo.text.trim().isEmpty
          ? 'Prova sem título'
          : _titulo.text.trim(),
      turmaId: _turmaId ?? '',
      data: data,
      questoes: _selecionadas.length,
      variacoes: variacoes.length,
      modo: modo,
      status: 'Pronta',
      corrigidas: 0,
      total: quantidade,
      professorId: FirestoreService.instance.professorId,
      variacoesDados: variacoes,
    );
  }

  Future<void> _gerar(List<Questao> banco, List<Aluno> alunosDaTurma) async {
    if (_selecionadas.isEmpty || _salvando || _turmaId == null) return;
    setState(() => _salvando = true);
    try {
      final prova = montarProva(banco, alunosDaTurma);
      await FirestoreService.instance.addProva(prova);
      if (!mounted) return;
      toast(context,
          'Prova salva com ${prova.variacoes} variação(ões) e gabarito.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) toast(context, 'Erro ao salvar a prova: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova prova')),
      body: StreamBuilder<List<Turma>>(
        stream: FirestoreService.instance.turmasStream(),
        builder: (context, snapTurmas) {
          final turmas = snapTurmas.data ?? [];
          if (_turmaId == null && turmas.isNotEmpty) {
            _turmaId = turmas.first.id;
          }
          return StreamBuilder<List<Aluno>>(
            stream: FirestoreService.instance.alunosStream(),
            builder: (context, snapAlunos) {
              final todos = snapAlunos.data ?? [];
              final daTurma =
                  todos.where((a) => a.turmaId == _turmaId).toList();
              return StreamBuilder<List<Questao>>(
                stream: FirestoreService.instance.questoesStream(),
                builder: (context, snapQuestoes) {
                  final banco = snapQuestoes.data ?? [];
                  if (!_inicializou && banco.isNotEmpty) {
                    _selecionadas
                        .addAll(banco.take(4).map((q) => q.id));
                    _inicializou = true;
                  }
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SectionCard(
                        title: 'Dados da prova',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titulo,
                              decoration:
                                  const InputDecoration(labelText: 'Título'),
                            ),
                            const SizedBox(height: 12),
                            Text('Turma',
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            if (turmas.isEmpty)
                              const Text(
                                  'Nenhuma turma cadastrada. Crie a turma '
                                  'primeiro, na aba "Turmas".')
                            else
                              Wrap(
                                spacing: 8,
                                children: turmas
                                    .map((t) => ChoiceChip(
                                          label: Text(t.nome),
                                          selected: t.id == _turmaId,
                                          onSelected: (_) =>
                                              setState(() => _turmaId = t.id),
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title:
                            'Questões · ${_selecionadas.length} selecionadas',
                        child: banco.isEmpty
                            ? Text(
                                snapQuestoes.connectionState ==
                                        ConnectionState.waiting
                                    ? 'Carregando questões…'
                                    : 'Nenhuma questão no banco. Cadastre na '
                                        'aba Questões.',
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              )
                            : Column(
                                children: banco.map((q) {
                                  final ativa =
                                      _selecionadas.contains(q.id);
                                  return CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: ativa,
                                    onChanged: (_) => setState(() {
                                      ativa
                                          ? _selecionadas.remove(q.id)
                                          : _selecionadas.add(q.id);
                                    }),
                                    title: Text(q.enunciado,
                                        style:
                                            const TextStyle(fontSize: 14)),
                                    subtitle: Text(
                                        '${q.assunto} · ${q.dificuldade} · '
                                        'gabarito ${q.correta}'),
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
                            onChanged: (v) =>
                                setState(() => _embQuestoes = v),
                            title: const Text(
                                'Embaralhar ordem das questões'),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _embAlternativas,
                            onChanged: (v) =>
                                setState(() => _embAlternativas = v),
                            title: const Text('Embaralhar alternativas'),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _individual,
                            onChanged: (v) =>
                                setState(() => _individual = v),
                            title: const Text('Uma variação por aluno'),
                            subtitle: const Text(
                                'Folha já sai com nome, matrícula e QR do '
                                'aluno.'),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Resumo',
                        child: Column(children: [
                          _linha(context, 'Turma',
                              turmas.isEmpty ? '—' : _turmaNome(turmas)),
                          _linha(context, 'Alunos na turma',
                              '${daTurma.length}'),
                          _linha(context, 'Questões',
                              '${_selecionadas.length}'),
                          _linha(
                              context,
                              'Variações',
                              _individual
                                  ? '${daTurma.isEmpty ? 1 : daTurma.length}'
                                  : '1'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _selecionadas.isEmpty ||
                                      _salvando ||
                                      _turmaId == null
                                  ? null
                                  : () => _gerar(banco, daTurma),
                              icon: const Icon(Icons.shuffle, size: 18),
                              label: Text(_salvando
                                  ? 'Salvando…'
                                  : 'Gerar e salvar prova'),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _turmaNome(List<Turma> turmas) {
    final t = turmas.where((x) => x.id == _turmaId);
    return t.isEmpty ? '—' : t.first.nome;
  }

  Widget _linha(BuildContext context, String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
            Text(valor,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
