import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

class PainelScreen extends StatelessWidget {
  const PainelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emAndamento = provas.where((p) => p.corrigidas < p.total).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageHeader(
          title: 'Painel',
          description:
              'Visão geral das provas, correções em andamento e últimas folhas lidas.',
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            MetricCard(
                label: 'Questões no banco',
                value: '${questoes.length}',
                icon: Icons.library_books_outlined),
            MetricCard(
                label: 'Provas criadas',
                value: '${provas.length}',
                icon: Icons.description_outlined),
            MetricCard(
                label: 'Folhas corrigidas',
                value: '${provas.fold<int>(0, (s, p) => s + p.corrigidas)}',
                icon: Icons.check_circle_outline),
            MetricCard(
                label: 'Alunos',
                value: '${turmas.fold<int>(0, (s, t) => s + t.alunos)}',
                icon: Icons.people_outline),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Correções em andamento',
          child: Column(
            children: emAndamento.map((p) {
              final pct = p.total == 0 ? 0.0 : p.corrigidas / p.total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(p.titulo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                        Text('${p.corrigidas}/${p.total}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(nomeTurma(p.turmaId),
                        style: Theme.of(context).textTheme.bodySmall),
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
            children: correcoes.map((c) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(nomeAluno(c.alunoId)),
                subtitle: Text('${c.variacao} · ${c.lidaEm}'),
                trailing: StatusBadge(
                  '${c.acertos}/${c.total} · ${c.nota.toStringAsFixed(1)}',
                  color: c.nota >= 6 ? AppColors.success : AppColors.danger,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
