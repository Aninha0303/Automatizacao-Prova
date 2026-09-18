import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'correcao_screen.dart';
import 'provas_screen.dart';

class PainelScreen extends StatelessWidget {
  const PainelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emAndamento = provas.where((p) => p.status == 'Aplicada').toList();
    final totalCorrigidas = provas.fold<int>(0, (s, p) => s + p.corrigidas);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageHeader(
          title: 'Bom trabalho, professor',
          description:
              'Semana de provas sob controle: gere, aplique e corrija sem levar pilha de papel para casa.',
        ),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NovaProvaScreen()),
              ),
              icon: const Icon(Icons.note_add_outlined, size: 18),
              label: const Text('Nova prova'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CorrecaoScreen()),
              ),
              icon: const Icon(Icons.document_scanner_outlined, size: 18),
              label: const Text('Corrigir agora'),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            MetricCard(
                label: 'Provas corrigidas',
                value: '$totalCorrigidas',
                hint: 'neste bimestre',
                icon: Icons.check_circle_outline),
            const MetricCard(
                label: 'Aguardando correção',
                value: '24',
                hint: 'folhas pendentes',
                icon: Icons.schedule_outlined),
            MetricCard(
                label: 'Questões no banco',
                value: '${questoes.length}',
                hint: 'reutilizáveis',
                icon: Icons.trending_up),
            const MetricCard(
                label: 'Tempo médio',
                value: '26 s',
                hint: 'por folha lida',
                icon: Icons.document_scanner_outlined),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Correção em andamento',
          child: Column(
            children: emAndamento.isEmpty
                ? [
                    Text('Nenhuma correção em andamento.',
                        style: Theme.of(context).textTheme.bodySmall),
                  ]
                : emAndamento.map((p) {
                    final pct = p.total == 0 ? 0.0 : p.corrigidas / p.total;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.titulo,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(nomeTurma(p.turmaId),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                              ),
                              Text('${p.corrigidas}/${p.total}',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: AppColors.border,
                              color: AppColors.primary,
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
          title: 'Últimas folhas lidas',
          child: Column(
            children: correcoes.take(5).map((c) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(nomeAluno(c.alunoId)),
                subtitle: Text('${c.variacao} · ${c.lidaEm}'),
                trailing: StatusBadge(
                  c.nota.toStringAsFixed(1),
                  color: c.nota >= 6 ? AppColors.primary : AppColors.danger,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
