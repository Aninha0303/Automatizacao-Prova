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
  String _assunto = 'Todos';

  @override
  Widget build(BuildContext context) {
    final assuntos = <String>['Todos', ...{...questoes.map((q) => q.assunto)}];
    final lista = questoes.where((q) {
      final okAssunto = _assunto == 'Todos' || q.assunto == _assunto;
      final okBusca =
          q.enunciado.toLowerCase().contains(_busca.toLowerCase());
      return okAssunto && okBusca;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeader(
          title: 'Banco de questões',
          description:
              'Questões com gabarito definido. O sistema embaralha enunciados e alternativas na hora de gerar as provas.',
          action: FilledButton.icon(
            onPressed: () =>
                toast(context, 'Cadastro de questão entra na próxima fase (N2).'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova questão'),
          ),
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar por enunciado',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _busca = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: assuntos.map((a) {
            final ativo = a == _assunto;
            return ativo
                ? FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      backgroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () => setState(() => _assunto = a),
                    child: Text(a),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () => setState(() => _assunto = a),
                    child: Text(a),
                  );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (lista.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Text('Nenhuma questão encontrada.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ...lista.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(q.disciplina, color: AppColors.muted),
                        StatusBadge(q.assunto),
                        Text('${q.dificuldade} · usada em ${q.usos} provas',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(q.enunciado,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ...q.alternativas.map((a) {
                      final correta = a.letra == q.correta;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: correta
                              ? AppColors.success.withOpacity(0.10)
                              : Colors.transparent,
                          border: Border.all(
                              color: correta
                                  ? AppColors.success.withOpacity(0.4)
                                  : AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.letra,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(a.texto)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
