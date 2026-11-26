import 'package:cloud_firestore/cloud_firestore.dart';

class Alternativa {
  final String letra;
  final String texto;
  const Alternativa(this.letra, this.texto);

  Map<String, dynamic> toMap() => {'letra': letra, 'texto': texto};

  static Alternativa fromMap(Map<String, dynamic> m) =>
      Alternativa(m['letra'] as String? ?? '', m['texto'] as String? ?? '');
}

class Questao {
  final String id;
  final String enunciado;
  final List<Alternativa> alternativas;
  final String correta;
  final String disciplina;

  const Questao({
    this.id = '',
    required this.enunciado,
    required this.alternativas,
    required this.correta,
    this.disciplina = '',
  });

  Map<String, dynamic> toMap() => {
        'enunciado': enunciado,
        'alternativas': alternativas.map((a) => a.toMap()).toList(),
        'correta': correta,
        'disciplina': disciplina,
      };

  static Questao fromMap(String id, Map<String, dynamic> m) {
    final brutas = (m['alternativas'] as List? ?? const []);
    return Questao(
      id: id,
      enunciado: m['enunciado'] as String? ?? '',
      alternativas: brutas
          .map((a) => Alternativa.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList(),
      correta: m['correta'] as String? ?? '',
      disciplina: m['disciplina'] as String? ?? '',
    );
  }
}

class Turma {
  final String id;
  final String nome;
  final String disciplina;
  final String professorId;

  const Turma({
    this.id = '',
    required this.nome,
    this.disciplina = '',
    this.professorId = '',
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'disciplina': disciplina,
        'professorId': professorId,
      };

  static Turma fromMap(String id, Map<String, dynamic> m) => Turma(
        id: id,
        nome: m['nome'] as String? ?? '',
        disciplina: m['disciplina'] as String? ?? '',
        professorId: m['professorId'] as String? ?? '',
      );
}

class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String turmaId;

  const Aluno({
    this.id = '',
    required this.nome,
    required this.matricula,
    required this.turmaId,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'matricula': matricula,
        'turmaId': turmaId,
      };

  static Aluno fromMap(String id, Map<String, dynamic> m) => Aluno(
        id: id,
        nome: m['nome'] as String? ?? '',
        matricula: m['matricula'] as String? ?? '',
        turmaId: m['turmaId'] as String? ?? '',
      );
}

/// Uma questão dentro de uma variação: ordem das alternativas definida na
/// criação da prova + a letra correta daquela ordem.
class QuestaoProva {
  final String questaoId;
  final List<Alternativa> alternativas;
  final String correta;

  const QuestaoProva({
    required this.questaoId,
    required this.alternativas,
    required this.correta,
  });

  Map<String, dynamic> toMap() => {
        'questaoId': questaoId,
        'alternativas': alternativas.map((a) => a.toMap()).toList(),
        'correta': correta,
      };

  static QuestaoProva fromMap(Map<String, dynamic> m) {
    final brutas = (m['alternativas'] as List? ?? const []);
    return QuestaoProva(
      questaoId: m['questaoId'] as String? ?? '',
      alternativas: brutas
          .map((a) => Alternativa.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList(),
      correta: m['correta'] as String? ?? '',
    );
  }
}

/// Versão embaralhada da prova (questões e alternativas em ordem própria).
class Variacao {
  final String id;
  final List<QuestaoProva> questoes;

  const Variacao({required this.id, required this.questoes});

  Map<String, dynamic> toMap() => {
        'id': id,
        'questoes': questoes.map((q) => q.toMap()).toList(),
      };

  static Variacao fromMap(Map<String, dynamic> m) {
    final brutas = (m['questoes'] as List? ?? const []);
    return Variacao(
      id: m['id'] as String? ?? '',
      questoes: brutas
          .map((b) => QuestaoProva.fromMap(Map<String, dynamic>.from(b as Map)))
          .toList(),
    );
  }
}

class Prova {
  final String id;
  final String titulo;
  final String turmaId;
  final String data;
  final String status;
  final int questoes;
  final int total;
  final int corrigidas;
  final int variacoes;
  final String professorId;
  final List<Variacao> variacoesDados;

  const Prova({
    this.id = '',
    required this.titulo,
    required this.turmaId,
    required this.data,
    this.status = 'Rascunho',
    this.questoes = 0,
    this.total = 0,
    this.corrigidas = 0,
    this.variacoes = 0,
    this.professorId = '',
    this.variacoesDados = const [],
  });

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'turmaId': turmaId,
        'data': data,
        'status': status,
        'questoes': questoes,
        'total': total,
        'corrigidas': corrigidas,
        'variacoes': variacoes,
        'professorId': professorId,
        'variacoes': variacoesDados.map((v) => v.toMap()).toList(),
      };

  static Prova fromMap(String id, Map<String, dynamic> m) {
    final varBrutas = (m['variacoes'] as List? ?? const []);
    return Prova(
      id: id,
      titulo: m['titulo'] as String? ?? '',
      turmaId: m['turmaId'] as String? ?? '',
      data: m['data'] as String? ?? '',
      status: m['status'] as String? ?? 'Rascunho',
      questoes: (m['questoes'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
      corrigidas: (m['corrigidas'] as num?)?.toInt() ?? 0,
      variacoes: (m['variacoes'] as num?)?.toInt() ?? 0,
      professorId: m['professorId'] as String? ?? '',
      variacoesDados: varBrutas
          .map((v) => Variacao.fromMap(Map<String, dynamic>.from(v as Map)))
          .toList(),
    );
  }

  Prova copyWith({String? status, int? corrigidas}) => Prova(
        id: id,
        titulo: titulo,
        turmaId: turmaId,
        data: data,
        status: status ?? this.status,
        questoes: questoes,
        total: total,
        corrigidas: corrigidas ?? this.corrigidas,
        variacoes: variacoes,
        professorId: professorId,
        variacoesDados: variacoesDados,
      );
}

class Resposta {
  final int questao;
  final String marcada;
  final String correta;

  const Resposta(this.questao, this.marcada, this.correta);

  bool get acertou => marcada.isNotEmpty && marcada == correta;

  Map<String, dynamic> toMap() =>
      {'questao': questao, 'marcada': marcada, 'correta': correta};

  static Resposta fromMap(Map<String, dynamic> m) => Resposta(
        (m['questao'] as num?)?.toInt() ?? 0,
        m['marcada'] as String? ?? '',
        m['correta'] as String? ?? '',
      );
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
    this.id = '',
    required this.alunoId,
    required this.provaId,
    required this.variacao,
    required this.acertos,
    required this.total,
    required this.nota,
    required this.lidaEm,
    this.respostas = const [],
  });

  Map<String, dynamic> toMap() => {
        'alunoId': alunoId,
        'provaId': provaId,
        'variacao': variacao,
        'acertos': acertos,
        'total': total,
        'nota': nota,
        'lidaEm': lidaEm,
        'respostas': respostas.map((r) => r.toMap()).toList(),
      };

  static Correcao fromMap(String id, Map<String, dynamic> m) {
    final brutas = (m['respostas'] as List? ?? const []);
    return Correcao(
      id: id,
      alunoId: m['alunoId'] as String? ?? '',
      provaId: m['provaId'] as String? ?? '',
      variacao: m['variacao'] as String? ?? '',
      acertos: (m['acertos'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
      nota: (m['nota'] as num?)?.toDouble() ?? 0,
      lidaEm: m['lidaEm'] as String? ?? '',
      respostas: brutas
          .map((r) => Resposta.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList(),
    );
  }
}
