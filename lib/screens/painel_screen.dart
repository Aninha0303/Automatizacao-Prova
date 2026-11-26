import 'package:flutter/material.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'correcao_screen.dart';
import 'provas_screen.dart';

/// Painel de controle com dados reais do Firebase.
class PainelScreen extends StatelessWidget {
  const PainelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Prova>>(
      stream: FirestoreService.instance.provasStream(),
      builder: (context, snapProvas) {
        final provas = snapProvas.data ?? [];
        return StreamBuilder<List<Correcao>>(
          stream: FirestoreService.instance.correcoesStream(),
          builder: (context, snapCorrecoes) {
            final correcoes = snapCorrecoes.data ?? [];
            return StreamBuilder<List<Questao>>(
              stream: FirestoreService.instance.questoesStream(),
              builder: (context, snapQuestoes) {
                final questoes = snapQuestoes.data ?? [];

                final pendentes = provas.fold<int>(0, (soma, p) {
                  final falta = p.total - p.corrigidas;
                  return soma + (falta > 0 ? falta : 0);
                });
                final emAndamento = provas
                    .where((p) =>
                        p.status == 'Aplicada' ||
                        (p.status == 'Pronta' && p.corrigidas > 0))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const PageHeader(
                      title: 'Painel',
                      description:
                          'Tudo vem do Firebase: provas, folhas corrigidas e o banco de questões.',
                    ),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const NovaProvaScreen()),
                          ),
                          icon: const Icon(Icons.note_add_outlined, size: 18),
                          label: const Text('Nova prova'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CorrecaoScreen()),
                          ),
                          icon:
                              const Icon(Icons.document_scanner_outlined,
                                  size: 18),
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
                            label: 'Provas no sistema',
                            value: '${provas.length}',
                            hint: 'criadas por você',
                            icon: Icons.description_outlined),
                        MetricCard(
                            label: 'Folhas corrigidas',
                            value: '${correcoes.length}',
                            hint: 'salvas no banco',
                            icon: Icons.check_circle_outline),
                        MetricCard(
                            label: 'Folhas pendentes',
                            value: '$pendentes',
                            hint: 'ainda sem nota',
                            icon: Icons.schedule_outlined),
                        MetricCard(
                            label: 'Questões no banco',
                            value: '${questoes.length}',
                            hint: 'reutilizáveis',
                            icon: Icons.library_books_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Correção em andamento',
                      child: Column(
                        children: emAndamento.isEmpty
                            ? [
                                Text(
                                    'Nenhuma prova com correção em andamento.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ]
                            : emAndamento.map((p) {
                                final pct = p.total == 0
                                    ? 0.0
                                    : p.corrigidas / p.total;
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(p.titulo,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          Text(
                                              '${p.corrigidas}/${p.total}',
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
                                          value: pct,
                                          minHeight: 6,
                                          backgroundColor:
                                              AppColors.border,
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
                      child: correcoes.isEmpty
                          ? Text(
                              'Nenhuma folha corrigida ainda. Abra a aba '
                              '"Correção" e leia o QR de uma folha.',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            )
                          : Column(
                              children: correcoes
                                  .take(5)
                                  .map((c) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        title: Text(c.alunoNome.isEmpty
                                            ? c.alunoId
                                            : c.alunoNome),
                                        subtitle: Text(
                                            '${c.variacao} · ${c.acertos}/${c.total} acertos'),
                                        trailing: StatusBadge(
                                          c.nota.toStringAsFixed(1),
                                          color: c.nota >= 6
                                              ? AppColors.primary
                                              : AppColors.danger,
                                        ),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
