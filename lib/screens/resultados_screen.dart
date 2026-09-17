import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media =
        correcoes.fold<double>(0, (s, c) => s + c.nota) / correcoes.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageHeader(
          title: 'Resultados',
          description:
              'Notas por aluno e distribuição das alternativas para análise pedagógica.',
        ),
        Row(children: [
          Expanded(
              child: MetricCard(
                  label: 'Média da turma',
                  value: media.toStringAsFixed(1),
                  icon: Icons.timeline)),
          const SizedBox(width: 12),
          Expanded(
              child: MetricCard(
                  label: 'Acima da média',
                  value:
                      '${correcoes.where((c) => c.nota >= media).length}/${correcoes.length}',
                  icon: Icons.trending_up)),
        ]),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Notas por aluno',
          child: Column(
            children: correcoes.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(nomeAluno(c.alunoId))),
                      Text('${c.acertos}/${c.total}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      StatusBadge(c.nota.toStringAsFixed(1),
                          color: c.nota >= 6
                              ? AppColors.success
                              : AppColors.danger),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: c.acertos / c.total,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: c.nota >= 6
                            ? AppColors.success
                            : AppColors.danger,
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
          title: 'Distribuição por questão',
          child: Column(
            children: estatisticaQuestoes.map((e) {
              final barras = {'A': e.a, 'B': e.b, 'C': e.c, 'D': e.d};
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.questao}. ${e.enunciado}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...barras.entries.map((b) {
                      final correta = b.key == e.correta;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          SizedBox(width: 16, child: Text(b.key)),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: b.value / e.totalRespostas,
                                minHeight: 8,
                                backgroundColor: AppColors.border,
                                color: correta
                                    ? AppColors.success
                                    : AppColors.muted.withOpacity(0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 28,
                              child: Text('${b.value}',
                                  textAlign: TextAlign.right,
                                  style:
                                      Theme.of(context).textTheme.bodySmall)),
                        ]),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
