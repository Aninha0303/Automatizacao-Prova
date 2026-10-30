import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mock_data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  /// Gera o texto da planilha (separado por ponto e vírgula) e copia —
  /// é só colar no Excel com Ctrl+V.
  Future<void> _exportar(BuildContext context, List<Correcao> correcoes,
      Map<String, String> nomes) async {
    if (correcoes.isEmpty) {
      toast(context, 'Nenhuma correção para exportar.');
      return;
    }
    final linhas = <String>['Aluno;Variação;Acertos;Total;Nota'];
    for (final c in correcoes) {
      linhas.add(
          '${nomes[c.alunoId] ?? c.alunoId};${c.variacao};${c.acertos};${c.total};${c.nota.toStringAsFixed(1)}');
    }
    await Clipboard.setData(ClipboardData(text: linhas.join('\n')));
    if (context.mounted) {
      toast(context, 'Planilha copiada — cole no Excel com Ctrl+V.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Correcao>>(
      stream: FirestoreService.instance.correcoesStream(),
      builder: (context, snap) {
        final correcoes = snap.data ?? [];
        return StreamBuilder<Map<String, String>>(
          stream: FirestoreService.instance.nomesAlunosStream(),
          builder: (context, snapNomes) {
            final nomes = snapNomes.data ?? {};

            // Estatísticas por questão, calculadas das respostas reais.
            final stats = <int, Map<String, int>>{};
            final gabarito = <int, String>{};
            for (final c in correcoes) {
              for (final r in c.respostas) {
                final m = stats.putIfAbsent(
                    r.questao, () => {'A': 0, 'B': 0, 'C': 0, 'D': 0});
                m[r.marcada] = (m[r.marcada] ?? 0) + 1;
                gabarito[r.questao] = r.correta;
              }
            }
            final questoesOrdenadas = stats.keys.toList()..sort();

            final media = correcoes.isEmpty
                ? 0.0
                : correcoes.map((c) => c.nota).reduce((a, b) => a + b) /
                    correcoes.length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: 'Resultados',
                  description:
                      'Notas por aluno e análise das alternativas marcadas — dados vindos do Firebase.',
                  action: OutlinedButton.icon(
                    onPressed: () => _exportar(context, correcoes, nomes),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Exportar'),
                  ),
                ),
                SectionCard(
                  title: 'Resumo',
                  child: Row(children: [
                    Expanded(
                      child: Text('Folhas corrigidas',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    Text('${correcoes.length}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text('Média da turma',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    StatusBadge(
                      media.toStringAsFixed(1),
                      color: media >= 6
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Análise por questão',
                  child: questoesOrdenadas.isEmpty
                      ? Text(
                          'Nenhuma correção ainda. Leia folhas na aba Correção.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : Column(
                          children: questoesOrdenadas.map((numero) {
                            final barras = stats[numero]!;
                            final correta = gabarito[numero] ?? '';
                            final totalRespostas = barras.values
                                .fold<int>(0, (soma, v) => soma + v);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text('Questão $numero',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                      const SizedBox(width: 8),
                                      StatusBadge('gab. $correta',
                                          color: AppColors.muted),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children:
                                        barras.entries.map((b) {
                                      final pct = totalRespostas == 0
                                          ? 0
                                          : (b.value /
                                                  totalRespostas *
                                                  100)
                                              .round();
                                      final certa = b.key == correta;
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 8),
                                          padding:
                                              const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: AppColors.border),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(b.key,
                                                      style:
                                                          const TextStyle(
                                                              fontSize:
                                                                  12)),
                                                  Text('$pct%',
                                                      style: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodySmall),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        999),
                                                child:
                                                    LinearProgressIndicator(
                                                  value: pct / 100,
                                                  minHeight: 6,
                                                  backgroundColor:
                                                      AppColors.border,
                                                  color: certa
                                                      ? AppColors.success
                                                      : AppColors.warning,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
                          style: Theme.of(context).textTheme.bodySmall)
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
                                            nomes[c.alunoId] ?? c.alunoId,
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
}
