import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

/// Folhas de resposta com QR code real (um QR por aluno/variação).
/// O conteúdo do QR segue o formato: provaId|variacao|matricula
class FolhasScreen extends StatelessWidget {
  final Prova prova;
  const FolhasScreen({super.key, required this.prova});

  @override
  Widget build(BuildContext context) {
    final turma = turmas.firstWhere((t) => t.id == prova.turmaId);
    final lista = alunos.where((a) => a.turmaId == prova.turmaId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Folhas de resposta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeader(
            title: prova.titulo,
            description:
                '${turma.nome} · ${prova.questoes} questões. Cada folha tem um QR code próprio.',
          ),
          for (var i = 0; i < lista.length; i++)
            _Folha(
              prova: prova,
              aluno: lista[i],
              variacao: 'V-${(i + 1).toString().padLeft(2, '0')}',
            ),
          if (lista.isEmpty)
            const SectionCard(child: Text('Nenhum aluno nesta turma.')),
        ],
      ),
    );
  }
}

class _Folha extends StatelessWidget {
  final Prova prova;
  final Aluno aluno;
  final String variacao;
  const _Folha({required this.prova, required this.aluno, required this.variacao});

  @override
  Widget build(BuildContext context) {
    final dados = '${prova.id}|$variacao|${aluno.matricula}';
    return SectionCard(
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
                    Text(aluno.nome,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Matrícula ${aluno.matricula} · $variacao',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.ink.withOpacity(0.15)),
                ),
                child: QrImageView(
                  data: dados,
                  size: 96,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GradeRespostas(questoes: prova.questoes),
        ],
      ),
    );
  }
}

class _GradeRespostas extends StatelessWidget {
  final int questoes;
  const _GradeRespostas({required this.questoes});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(questoes, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              child: Text('${i + 1}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            for (final letra in ['A', 'B', 'C', 'D'])
              Container(
                margin: const EdgeInsets.only(right: 4),
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink.withOpacity(0.35)),
                ),
                child: Text(letra, style: const TextStyle(fontSize: 10)),
              ),
          ],
        );
      }),
    );
  }
}
