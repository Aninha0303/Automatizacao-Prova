import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Relatório por prova (requisito 9): notas, situação e análise por questão,
/// usando só as correções salvas no Firebase.
class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({super.key});
  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  String? _provaId;

  Future<void> _exportar(
      BuildContext context, List<Correcao> correcoes) async {
    if (correcoes.isEmpty) {
      toast(context, 'Nenhuma correção para exportar.');
      return;
    }
    final linhas = <String>['Aluno;Variação;Acertos;Total;Nota'];
    for (final c in correcoes) {
      linhas.add(
          '${c.alunoNome};${c.variacao};${c.acertos};${c.total};${c.nota.toStringAsFixed(1)}');
    }
    await Clipboard.setData(ClipboardData(text: linhas.join('\n')));
    if (context.mounted) {
      toast(context, 'Planilha copiada — cole no Excel com Ctrl+V.');
    }
  }

  Future<void> _finalizar(Prova p) async {
    await FirestoreService.instance
        .updateProva(p.copyWith(status: 'Corrigida'));
    if (mounted) {
      toast(context, 'Prova finalizada: status "Corrigida".');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Prova>>(
      stream: FirestoreService.instance.provasStream(),
      builder: (context, snapProvas) {
        final provas = snapProvas.data ?? [];
        if (provas.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              PageHeader(
                title: 'Resultados',
                description:
                    'Notas e análise por questão, separadas por prova.',
              ),
              SectionCard(
                  child: Text('Nenhuma prova ainda. Crie uma em "Provas".')),
            ],
          );
        }
        if (_provaId == null ||
            !provas.any((p) => p.id == _provaId)) {
          _provaId = provas.first.id;
        }
        final prova = provas.firstWhere((p) => p.id == _provaId);

        return StreamBuilder<List<Correcao>>(
          stream: FirestoreService.instance.correcoesDaProvaStream(_provaId!),
          builder: (context, snap) {
            final correcoes = snap.data ?? [];

            final media = correcoes.isEmpty
                ? 0.0
                : correcoes.map((c) => c.nota).reduce((a, b) => a + b) /
                    correcoes.length;
            final aprovados =
                correcoes.where((c) => c.nota >= 6).length;

            // Análise por posição da questão na variação.
            final porQuestao = <int, List<int>>{};
            for (final c in correcoes) {
              for (final r in c.respostas) {
                final lista = porQuestao.putIfAbsent(r.questao, () => []);
                lista.add(r.acertou ? 1 : 0);
              }
            }
            final questoesOrdenadas = porQuestao.keys.toList()..sort();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: 'Resultados',
                  description:
                      'Escolha a prova para ver as notas e a análise das '
                      'alternativas marcadas.',
                  action: OutlinedButton.icon(
                    onPressed: () => _exportar(context, correcoes),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Exportar'),
                  ),
                ),
                SectionCard(
                  title: 'Prova',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _provaId,
                        decoration:
                            const InputDecoration(labelText: 'Prova'),
                        items: provas
                            .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.titulo} · ${p.status}')))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _provaId = v ?? _provaId),
                      ),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        StatusBadge(prova.status,
                            color: statusColor(prova.status)),
                        StatusBadge('${prova.questoes} questões',
                            color: AppColors.muted),
                        StatusBadge(
                            'corrigidas ${prova.corrigidas}/${prova.total}',
                            color: AppColors.muted),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: prova.status == 'Corrigida'
                              ? null
                              : () => _finalizar(prova),
                          icon: const Icon(Icons.done_all, size: 18),
                          label: Text(prova.status == 'Corrigida'
                              ? 'Correção já finalizada'
                              : 'Finalizar e divulgar notas'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Resumo',
                  child: Column(
                    children: [
                      _linhaResumoTexto(context, 'Folhas corrigidas',
                          '${correcoes.length}'),
                      _linhaResumoTexto(context, 'Aprovados (nota ≥ 6)',
                          '$aprovados de ${correcoes.length}'),
                      _linhaResumo(
                          context,
                          'Média da turma',
                          StatusBadge(
                            media.toStringAsFixed(1),
                            color: media >= 6
                                ? AppColors.success
                                : AppColors.danger,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Análise por questão',
                  child: questoesOrdenadas.isEmpty
                      ? Text(
                          'Nenhuma correção nesta prova. Leia folhas na aba '
                          'Correção.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : Column(
                          children: questoesOrdenadas.map((numero) {
                            final acertos = porQuestao[numero]!;
                            final totalQ = acertos.length;
                            final acertaram =
                                acertos.fold<int>(0, (s, v) => s + v);
                            final pct = totalQ == 0
                                ? 0
                                : (acertaram / totalQ * 100).round();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('Questão $numero',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                      Text('$acertaram/$totalQ acertaram',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: pct / 100,
                                      minHeight: 6,
                                      backgroundColor: AppColors.border,
                                      color: pct >= 60
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Notas da turma',
                  child: correcoes.isEmpty
                      ? Text('Nenhuma nota ainda.',
                          style:
                              Theme.of(context).textTheme.bodySmall)
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Expanded(
                                    flex: 4,
                                    child: Text('Aluno',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Variação',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Acertos',
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Nota',
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)),
                              ]),
                            ),
                            const Divider(
                                height: 1, color: AppColors.border),
                            ...correcoes.map((c) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  child: Row(children: [
                                    Expanded(
                                        flex: 4,
                                        child: Text(
                                            c.alunoNome.isEmpty
                                                ? c.alunoId
                                                : c.alunoNome,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w500))),
                                    Expanded(
                                        flex: 2,
                                        child: Text(c.variacao,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            '${c.acertos}/${c.total}',
                                            textAlign: TextAlign.right)),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment:
                                            Alignment.centerRight,
                                        child: StatusBadge(
                                            c.nota.toStringAsFixed(1),
                                            color: c.nota >= 6
                                                ? AppColors.primary
                                                : AppColors.danger),
                                      ),
                                    ),
                                  ]),
                                )),
                          ],
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _linhaResumo(BuildContext context, String rotulo, Widget valor) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
            valor,
          ],
        ),
      );

  Widget _linhaResumoTexto(BuildContext context, String rotulo, String valor) =>
      _linhaResumo(
          context,
          rotulo,
          Text(valor,
              style: const TextStyle(fontWeight: FontWeight.w600)));
}
