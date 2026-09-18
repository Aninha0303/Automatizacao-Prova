import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prova = provas.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeader(
          title: 'Resultados',
          description:
              '${prova.titulo} — notas por aluno e análise das alternativas marcadas.',
          action: OutlinedButton.icon(
            onPressed: () => toast(context, 'Planilha de notas gerada (mock).'),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Exportar'),
          ),
        ),
        SectionCard(
          title: 'Análise por questão',
          child: Column(
            children: estatisticaQuestoes.map((e) {
              final barras = {'A': e.a, 'B': e.b, 'C': e.c, 'D': e.d};
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text('Q${e.questao}  ${e.enunciado}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge('gab. ${e.correta}',
                            color: AppColors.muted),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: barras.entries.map((b) {
                        final pct =
                            (b.value / e.totalRespostas * 100).round();
                        final certa = b.key == e.correta;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(b.key,
                                        style: const TextStyle(fontSize: 12)),
                                    Text('$pct%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: pct / 100,
                                    minHeight: 6,
                                    backgroundColor: AppColors.border,
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(
                      flex: 4,
                      child: Text('Aluno',
                          style: Theme.of(context).textTheme.bodySmall)),
                  Expanded(
                      flex: 2,
                      child: Text('Variação',
                          style: Theme.of(context).textTheme.bodySmall)),
                  Expanded(
                      flex: 2,
                      child: Text('Acertos',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall)),
                  Expanded(
                      flex: 2,
                      child: Text('Nota',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall)),
                ]),
              ),
              const Divider(height: 1, color: AppColors.border),
              ...correcoes.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Expanded(
                          flex: 4,
                          child: Text(nomeAluno(c.alunoId),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500))),
                      Expanded(
                          flex: 2,
                          child: Text(c.variacao,
                              style: Theme.of(context).textTheme.bodySmall)),
                      Expanded(
                          flex: 2,
                          child: Text('${c.acertos}/${c.total}',
                              textAlign: TextAlign.right)),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: StatusBadge(c.nota.toStringAsFixed(1),
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
  }
}
