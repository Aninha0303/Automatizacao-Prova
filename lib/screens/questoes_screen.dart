import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

class QuestoesScreen extends StatefulWidget {
  const QuestoesScreen({super.key});
  @override
  State<QuestoesScreen> createState() => _QuestoesScreenState();
}

class _QuestoesScreenState extends State<QuestoesScreen> {
  String _busca = '';
  String _disciplina = 'Todas';

  @override
  Widget build(BuildContext context) {
    final disciplinas = <String>{'Todas', ...questoes.map((q) => q.disciplina)};
    final lista = questoes.where((q) {
      final okDisc = _disciplina == 'Todas' || q.disciplina == _disciplina;
      final okBusca = _busca.isEmpty ||
          q.enunciado.toLowerCase().contains(_busca.toLowerCase()) ||
          q.assunto.toLowerCase().contains(_busca.toLowerCase());
      return okDisc && okBusca;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeader(
          title: 'Banco de questões',
          description: 'Reaproveite questões e gabaritos em qualquer prova.',
          action: FilledButton.icon(
            onPressed: () => toast(context, 'Cadastro de questão na fase N2.'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova'),
          ),
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar por enunciado ou assunto',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _busca = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: disciplinas
              .map((d) => ChoiceChip(
                    label: Text(d),
                    selected: _disciplina == d,
                    onSelected: (_) => setState(() => _disciplina = d),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        ...lista.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.enunciado,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ...q.alternativas.map((a) {
                      final correta = a.letra == q.correta;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: correta
                                    ? AppColors.success.withOpacity(0.12)
                                    : Colors.transparent,
                                border: Border.all(
                                    color: correta
                                        ? AppColors.success
                                        : AppColors.border),
                              ),
                              child: Text(a.letra,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: correta
                                          ? AppColors.success
                                          : AppColors.muted)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(a.texto)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      StatusBadge(q.assunto),
                      StatusBadge(q.dificuldade, color: AppColors.warning),
                      StatusBadge('usada ${q.usos}×', color: AppColors.muted),
                    ]),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
