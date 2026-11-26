import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Folhas de resposta com QR code real (um QR por aluno/variação).
/// O conteúdo do QR é sempre: provaId|variacao|matricula
class FolhasScreen extends StatelessWidget {
  final Prova prova;
  const FolhasScreen({super.key, required this.prova});

  Future<void> _pdf(BuildContext context) async {
    final s = FirestoreService.instance;
    final alunos = await s.alunosStream().first;
    final turmas = await s.turmasStream().first;
    final questoes = await s.questoesStream().first;
    if (!context.mounted) return;

    final daTurma = alunos.where((a) => a.turmaId == prova.turmaId).toList();
    if (daTurma.isEmpty) {
      toast(context, 'Nenhum aluno nessa turma.');
      return;
    }
    if (prova.variacoesDados.isEmpty) {
      toast(context, 'A prova não tem variações salvas.');
      return;
    }
    final t = turmas.where((x) => x.id == prova.turmaId);
    final turmaNome = t.isEmpty ? 'Turma' : t.first.nome;
    final banco = {for (final q in questoes) q.id: q};

    try {
      await PdfService.gerarProva(
        prova: prova,
        turmaNome: turmaNome,
        alunos: daTurma,
        banco: banco,
      );
    } catch (e) {
      if (context.mounted) {
        toast(context, 'Não foi possível gerar o PDF: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folhas de resposta')),
      body: StreamBuilder<List<Aluno>>(
        stream: FirestoreService.instance.alunosStream(),
        builder: (context, snap) {
          final todos = snap.data ?? [];
          final lista =
              todos.where((a) => a.turmaId == prova.turmaId).toList();
          final temVariacoes = prova.variacoesDados.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PageHeader(
                title: prova.titulo,
                description: temVariacoes
                    ? '${lista.length} folhas · cada uma com QR próprio '
                        '(prova, variação e matrícula).'
                    : 'A prova não tem variações salvas: gere a prova de novo.',
                action: OutlinedButton.icon(
                  onPressed: () => _pdf(context),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: const Text('PDF'),
                ),
              ),
              if (lista.isEmpty)
                const SectionCard(
                    child: Text('Nenhum aluno nesta turma.')),
              if (!temVariacoes && lista.isNotEmpty)
                const SectionCard(
                    child: Text(
                        'Abra a prova em "Provas → Abrir" e gere as variações.')),
              for (var i = 0; i < lista.length && temVariacoes; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _Folha(
                    prova: prova,
                    aluno: lista[i],
                    variacao:
                        prova.variacoesDados[i % prova.variacoesDados.length],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Folha extends StatelessWidget {
  final Prova prova;
  final Aluno aluno;
  final Variacao variacao;
  const _Folha({
    required this.prova,
    required this.aluno,
    required this.variacao,
  });

  @override
  Widget build(BuildContext context) {
    final dados = '${prova.id}|${variacao.id}|${aluno.matricula}';
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
                    Text('Matrícula ${aluno.matricula} · ${variacao.id}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text('QR: $dados',
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
          _GradeRespostas(questoes: variacao.questoes.length),
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
