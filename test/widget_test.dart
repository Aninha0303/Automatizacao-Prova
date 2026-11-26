import 'package:flutter_test/flutter_test.dart';

import 'package:corrige_mais/models.dart';

void main() {
  test('variação guarda ordem e gabarito e volta do banco igual', () {
    final variacao = Variacao(id: 'V-01', questoes: [
      QuestaoProva(
        questaoId: 'q1',
        alternativas: const [
          Alternativa('A', '6 N'),
          Alternativa('B', '12 N'),
        ],
        correta: 'B',
      ),
    ]);

    final deVolta = Variacao.fromMap(variacao.toMap());

    expect(deVolta.id, 'V-01');
    expect(deVolta.questoes.length, 1);
    expect(deVolta.questoes.first.correta, 'B');
    expect(deVolta.questoes.first.alternativas.first.texto, '6 N');
  });

  test('nota vem dos acertos divididos pelo total', () {
    const correcao = Correcao(
      id: '',
      alunoId: 'a1',
      provaId: 'p1',
      variacao: 'V-01',
      acertos: 2,
      total: 4,
      nota: 2 / 4 * 10,
      lidaEm: '2026-11-26T00:00:00.000',
      respostas: [
        Resposta(1, 'A', 'A'),
        Resposta(2, 'B', 'C'),
      ],
    );

    expect(correcao.nota, 5.0);
    expect(correcao.respostas.first.acertou, isTrue);
    expect(correcao.respostas.last.acertou, isFalse);
  });
}
