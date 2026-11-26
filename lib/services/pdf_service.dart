import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models.dart';

/// Gera o PDF da prova: questões (páginas 1..n), gabarito (página separada)
/// e a folha de resposta com QR code em página separada.
class PdfService {
  static const _letras = ['A', 'B', 'C', 'D'];

  /// Monta o PDF e abre a tela de impressão/salvar como PDF.
  static Future<void> gerarProva({
    required Prova prova,
    required String turmaNome,
    required List<Aluno> alunos,
    required Map<String, Questao> banco,
  }) async {
    if (prova.variacoesDados.isEmpty || alunos.isEmpty) {
      throw StateError('A prova precisa de pelo menos uma variação e um aluno.');
    }

    final doc = pw.Document();

    // 1) Questões de cada aluno, na ordem embaralhada da sua variação.
    for (var i = 0; i < alunos.length; i++) {
      final variacao = prova.variacoesDados[i % prova.variacoesDados.length];
      doc.addPage(_paginaQuestoes(prova, turmaNome, alunos[i], variacao, banco));
    }

    // 2) Gabarito em página separada.
    doc.addPage(_paginaGabarito(prova, turmaNome));

    // 3) Folha de resposta com QR em página separada.
    for (var i = 0; i < alunos.length; i++) {
      final variacao = prova.variacoesDados[i % prova.variacoesDados.length];
      doc.addPage(_paginaFolha(prova, turmaNome, alunos[i], variacao));
    }

    await Printing.layoutPdf(
      name: 'CorrigeMais-${prova.titulo}',
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static pw.Page _paginaQuestoes(Prova prova, String turmaNome, Aluno aluno,
      Variacao variacao, Map<String, Questao> banco) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cabecalho(prova, turmaNome,
              extra: '${aluno.nome} · Matrícula ${aluno.matricula} · '
                  'Variação ${variacao.id}'),
          pw.SizedBox(height: 10),
          pw.Text('Responda marcando apenas uma alternativa por questão.',
              style: pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 12),
          for (var i = 0; i < variacao.questoes.length; i++) ...[
            _blocoQuestao(i + 1, variacao.questoes[i], banco),
            pw.SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  static pw.Widget _blocoQuestao(
      int numero, QuestaoProva qp, Map<String, Questao> banco) {
    final original = banco[qp.questaoId];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$numero. ${original?.enunciado ?? 'Questão'}',
            style: pw.TextStyle(fontSize: 10.5)),
        pw.SizedBox(height: 3),
        for (var j = 0; j < qp.alternativas.length; j++)
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 12, bottom: 2),
            child: pw.Text(
                '${qp.alternativas[j].letra}) ${qp.alternativas[j].texto}',
                style: pw.TextStyle(fontSize: 9.5)),
          ),
      ],
    );
  }

  static pw.Page _paginaGabarito(Prova prova, String turmaNome) {
    final total = prova.variacoesDados.isEmpty
        ? 0
        : prova.variacoesDados.first.questoes.length;
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cabecalho(prova, turmaNome, extra: 'Gabarito oficial'),
          pw.SizedBox(height: 14),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
            children: [
              pw.TableRow(children: [
                _celula('Questão', destaque: true),
                for (final v in prova.variacoesDados) _celula(v.id, destaque: true),
              ]),
              for (var i = 0; i < total; i++)
                pw.TableRow(children: [
                  _celula('${i + 1}'),
                  for (final v in prova.variacoesDados)
                    _celula(i < v.questoes.length
                        ? v.questoes[i].correta
                        : '—'),
                ]),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text(
              'Gabarito gerado junto com as variações: cada coluna é a letra '
              'correta na ordem embaralhada daquela folha.',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  static pw.Widget _celula(String texto, {bool destaque = false}) => pw.Container(
        padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(texto,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  static pw.Page _paginaFolha(
      Prova prova, String turmaNome, Aluno aluno, Variacao variacao) {
    final dadosQr = '${prova.id}|${variacao.id}|${aluno.matricula}';
    final total = variacao.questoes.length;
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cabecalho(prova, turmaNome,
              extra: '${aluno.nome} · Matrícula ${aluno.matricula} · '
                  'Variação ${variacao.id}'),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                    'Folha de resposta — preencha com lápis escuro, '
                    'sem rasurar. A leitura é feita pelo QR code abaixo.',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              ),
              pw.SizedBox(width: 12),
              pw.Container(
                padding: pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
                ),
                child: QrImage(data: dadosQr, size: 96),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text('QR: $dadosQr',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 14),
          for (var i = 0; i < total; i++)
            pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(children: [
                pw.SizedBox(
                    width: 22,
                    child: pw.Text('${i + 1}',
                        style: pw.TextStyle(fontSize: 9.5))),
                for (final letra in _letras) ...[
                  pw.Container(
                    width: 13,
                    height: 13,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: PdfColors.grey700, width: 0.6),
                    ),
                  ),
                  pw.SizedBox(width: 3),
                  pw.Text(letra, style: pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(width: 10),
                ],
              ]),
            ),
        ],
      ),
    );
  }

  static pw.Widget _cabecalho(Prova prova, String turmaNome, {String? extra}) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Corrige+',
              style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900)),
          pw.SizedBox(height: 2),
          pw.Text(prova.titulo,
              style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 2),
          pw.Text(
              '$turmaNome · ${prova.data} · ${prova.questoes} questões · '
              '${prova.variacoes} variação(ões)',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          if (extra != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(extra,
                style: pw.TextStyle(fontSize: 9.5)),
          ],
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.grey500, thickness: 0.6),
        ],
      );
}
