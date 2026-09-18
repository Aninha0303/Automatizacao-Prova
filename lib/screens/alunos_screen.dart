import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

class AlunosScreen extends StatelessWidget {
  const AlunosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeader(
          title: 'Turmas e alunos',
          description:
              'A lista importada alimenta a geração de folhas individualizadas com QR code.',
          action: OutlinedButton.icon(
            onPressed: () => toast(context, 'Importação de planilha na fase N2.'),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Importar planilha'),
          ),
        ),
        ...turmas.map((t) {
          final lista = alunos.where((a) => a.turmaId == t.id).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SectionCard(
              title: t.nome,
              trailing: StatusBadge('${t.disciplina} · ${t.alunos} alunos',
                  color: AppColors.muted),
              child: Column(
                children: lista
                    .map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(a.nome)),
                              Text(a.matricula,
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        }),
      ],
    );
  }
}
