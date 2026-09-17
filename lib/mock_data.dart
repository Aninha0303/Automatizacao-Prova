// Dados simulados (fase N1) — trocar por API/banco depois.

class Alternativa {
  final String letra;
  final String texto;
  const Alternativa(this.letra, this.texto);
}

class Questao {
  final String id;
  final String enunciado;
  final String disciplina;
  final String assunto;
  final String dificuldade; // Fácil | Média | Difícil
  final List<Alternativa> alternativas;
  final String correta;
  final int usos;
  const Questao({
    required this.id,
    required this.enunciado,
    required this.disciplina,
    required this.assunto,
    required this.dificuldade,
    required this.alternativas,
    required this.correta,
    required this.usos,
  });
}

class Turma {
  final String id;
  final String nome;
  final String disciplina;
  final int alunos;
  const Turma(this.id, this.nome, this.disciplina, this.alunos);
}

class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String turmaId;
  const Aluno(this.id, this.nome, this.matricula, this.turmaId);
}

class Prova {
  final String id;
  final String titulo;
  final String turmaId;
  final String data;
  final int questoes;
  final int variacoes;
  final String modo;
  final String status; // Rascunho | Pronta | Aplicada | Corrigida
  final int corrigidas;
  final int total;
  const Prova({
    required this.id,
    required this.titulo,
    required this.turmaId,
    required this.data,
    required this.questoes,
    required this.variacoes,
    required this.modo,
    required this.status,
    required this.corrigidas,
    required this.total,
  });
}

class Resposta {
  final int questao;
  final String marcada;
  final String correta;
  const Resposta(this.questao, this.marcada, this.correta);
  bool get acertou => marcada == correta;
}

class Correcao {
  final String id;
  final String alunoId;
  final String provaId;
  final String variacao;
  final int acertos;
  final int total;
  final double nota;
  final String lidaEm;
  final List<Resposta> respostas;
  const Correcao({
    required this.id,
    required this.alunoId,
    required this.provaId,
    required this.variacao,
    required this.acertos,
    required this.total,
    required this.nota,
    required this.lidaEm,
    required this.respostas,
  });
}

class EstatisticaQuestao {
  final int questao;
  final String enunciado;
  final int a, b, c, d;
  final String correta;
  const EstatisticaQuestao(
      this.questao, this.enunciado, this.a, this.b, this.c, this.d, this.correta);
  int get totalRespostas => a + b + c + d;
}

const turmas = <Turma>[
  Turma('t1', '3º A — Manhã', 'Física', 38),
  Turma('t2', '3º B — Manhã', 'Física', 41),
  Turma('t3', '2º C — Tarde', 'Matemática', 35),
];

const alunos = <Aluno>[
  Aluno('a1', 'Ana Beatriz Duarte', '2024001', 't1'),
  Aluno('a2', 'Bruno Carvalho', '2024002', 't1'),
  Aluno('a3', 'Carla Menezes', '2024003', 't1'),
  Aluno('a4', 'Diego Ramos', '2024004', 't1'),
  Aluno('a5', 'Elisa Prado', '2024005', 't1'),
  Aluno('a6', 'Felipe Nogueira', '2024006', 't2'),
  Aluno('a7', 'Giovana Lins', '2024007', 't2'),
  Aluno('a8', 'Henrique Sales', '2024008', 't3'),
];

const questoes = <Questao>[
  Questao(
    id: 'q1',
    enunciado:
        'Um corpo de 2 kg é acelerado a 3 m/s². Qual é o módulo da força resultante aplicada sobre ele?',
    disciplina: 'Física',
    assunto: 'Leis de Newton',
    dificuldade: 'Fácil',
    alternativas: [
      Alternativa('A', '1,5 N'),
      Alternativa('B', '5 N'),
      Alternativa('C', '6 N'),
      Alternativa('D', '12 N'),
    ],
    correta: 'C',
    usos: 7,
  ),
  Questao(
    id: 'q2',
    enunciado:
        'Um objeto é lançado verticalmente para cima. No ponto mais alto da trajetória, é correto afirmar que:',
    disciplina: 'Física',
    assunto: 'Cinemática',
    dificuldade: 'Média',
    alternativas: [
      Alternativa('A', 'a velocidade e a aceleração são nulas'),
      Alternativa('B', 'a velocidade é nula e a aceleração vale g'),
      Alternativa('C', 'a velocidade é máxima e a aceleração é nula'),
      Alternativa('D', 'ambas apontam para cima'),
    ],
    correta: 'B',
    usos: 12,
  ),
  Questao(
    id: 'q3',
    enunciado:
        'Em um circuito de resistores em série, o que permanece igual em todos os resistores?',
    disciplina: 'Física',
    assunto: 'Eletrodinâmica',
    dificuldade: 'Fácil',
    alternativas: [
      Alternativa('A', 'A tensão'),
      Alternativa('B', 'A potência'),
      Alternativa('C', 'A corrente'),
      Alternativa('D', 'A resistência'),
    ],
    correta: 'C',
    usos: 4,
  ),
  Questao(
    id: 'q4',
    enunciado:
        'Um gás ideal sofre uma transformação isotérmica. Sobre essa transformação, é correto afirmar que:',
    disciplina: 'Física',
    assunto: 'Termodinâmica',
    dificuldade: 'Difícil',
    alternativas: [
      Alternativa('A', 'a temperatura varia e o volume é constante'),
      Alternativa('B', 'o produto pressão × volume permanece constante'),
      Alternativa('C', 'não há troca de calor com o meio'),
      Alternativa('D', 'a energia interna aumenta'),
    ],
    correta: 'B',
    usos: 9,
  ),
  Questao(
    id: 'q5',
    enunciado: 'Qual das grandezas abaixo é vetorial?',
    disciplina: 'Física',
    assunto: 'Fundamentos',
    dificuldade: 'Fácil',
    alternativas: [
      Alternativa('A', 'Massa'),
      Alternativa('B', 'Temperatura'),
      Alternativa('C', 'Tempo'),
      Alternativa('D', 'Aceleração'),
    ],
    correta: 'D',
    usos: 15,
  ),
  Questao(
    id: 'q6',
    enunciado: 'A soma das raízes da equação x² − 7x + 10 = 0 é igual a:',
    disciplina: 'Matemática',
    assunto: 'Equação do 2º grau',
    dificuldade: 'Média',
    alternativas: [
      Alternativa('A', '−7'),
      Alternativa('B', '3'),
      Alternativa('C', '7'),
      Alternativa('D', '10'),
    ],
    correta: 'C',
    usos: 6,
  ),
];

const provas = <Prova>[
  Prova(
    id: 'p1',
    titulo: 'Avaliação Bimestral — Mecânica',
    turmaId: 't1',
    data: '24/08/2026',
    questoes: 20,
    variacoes: 38,
    modo: 'Mesmas questões embaralhadas',
    status: 'Corrigida',
    corrigidas: 38,
    total: 38,
  ),
  Prova(
    id: 'p2',
    titulo: 'Recuperação — Eletrodinâmica',
    turmaId: 't2',
    data: '31/08/2026',
    questoes: 15,
    variacoes: 41,
    modo: 'Mesmas questões embaralhadas',
    status: 'Aplicada',
    corrigidas: 17,
    total: 41,
  ),
  Prova(
    id: 'p3',
    titulo: 'Simulado — Álgebra',
    turmaId: 't3',
    data: '10/09/2026',
    questoes: 25,
    variacoes: 35,
    modo: 'Provas diferentes',
    status: 'Pronta',
    corrigidas: 0,
    total: 35,
  ),
];

const correcoes = <Correcao>[
  Correcao(
    id: 'c1',
    alunoId: 'a1',
    provaId: 'p1',
    variacao: 'V-07',
    acertos: 18,
    total: 20,
    nota: 9,
    lidaEm: 'há 2 min',
    respostas: [
      Resposta(1, 'C', 'C'),
      Resposta(2, 'B', 'B'),
      Resposta(3, 'A', 'C'),
      Resposta(4, 'B', 'B'),
      Resposta(5, 'D', 'D'),
    ],
  ),
  Correcao(
    id: 'c2',
    alunoId: 'a2',
    provaId: 'p1',
    variacao: 'V-12',
    acertos: 13,
    total: 20,
    nota: 6.5,
    lidaEm: 'há 4 min',
    respostas: [
      Resposta(1, 'B', 'C'),
      Resposta(2, 'B', 'B'),
      Resposta(3, 'C', 'C'),
      Resposta(4, 'A', 'B'),
      Resposta(5, 'D', 'D'),
    ],
  ),
  Correcao(
    id: 'c3',
    alunoId: 'a3',
    provaId: 'p1',
    variacao: 'V-03',
    acertos: 20,
    total: 20,
    nota: 10,
    lidaEm: 'há 6 min',
    respostas: [
      Resposta(1, 'C', 'C'),
      Resposta(2, 'B', 'B'),
      Resposta(3, 'C', 'C'),
      Resposta(4, 'B', 'B'),
      Resposta(5, 'D', 'D'),
    ],
  ),
  Correcao(
    id: 'c4',
    alunoId: 'a4',
    provaId: 'p1',
    variacao: 'V-21',
    acertos: 9,
    total: 20,
    nota: 4.5,
    lidaEm: 'há 9 min',
    respostas: [
      Resposta(1, 'A', 'C'),
      Resposta(2, 'A', 'B'),
      Resposta(3, 'C', 'C'),
      Resposta(4, 'D', 'B'),
      Resposta(5, 'B', 'D'),
    ],
  ),
  Correcao(
    id: 'c5',
    alunoId: 'a5',
    provaId: 'p1',
    variacao: 'V-30',
    acertos: 16,
    total: 20,
    nota: 8,
    lidaEm: 'há 12 min',
    respostas: [
      Resposta(1, 'C', 'C'),
      Resposta(2, 'D', 'B'),
      Resposta(3, 'C', 'C'),
      Resposta(4, 'B', 'B'),
      Resposta(5, 'D', 'D'),
    ],
  ),
];

const estatisticaQuestoes = <EstatisticaQuestao>[
  EstatisticaQuestao(1, 'Força resultante (2ª Lei)', 6, 9, 21, 2, 'C'),
  EstatisticaQuestao(2, 'Lançamento vertical', 5, 19, 3, 11, 'B'),
  EstatisticaQuestao(3, 'Resistores em série', 12, 4, 20, 2, 'C'),
  EstatisticaQuestao(4, 'Transformação isotérmica', 8, 11, 14, 5, 'B'),
  EstatisticaQuestao(5, 'Grandeza vetorial', 3, 2, 4, 29, 'D'),
];

String nomeTurma(String id) =>
    turmas.where((t) => t.id == id).map((t) => t.nome).firstOrNull ?? '—';

String nomeAluno(String id) =>
    alunos.where((a) => a.id == id).map((a) => a.nome).firstOrNull ?? '—';

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
