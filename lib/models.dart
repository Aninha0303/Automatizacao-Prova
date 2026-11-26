/// Modelos de dados do Corrige+ (N3).
/// Tudo aqui é preenchido a partir do Firestore — nada de dados de exemplo.

class Alternativa {
  final String letra;
  final String texto;
  const Alternativa(this.letra, this.texto);

  Map<String, dynamic> toMap() => {'letra': letra, 'texto': texto};

  factory Alternativa.fromMap(Map<String, dynamic> m) => Alternativa(
        (m['letra'] ?? '') as String,
        (m['texto'] ?? '') as String,
      );
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
  const Turma({required this.id, required this.nome, required this.disciplina});
}

class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String turmaId;
  const Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.turmaId,
  });
}

/// Uma questão dentro de uma variação: alternativas já embaralhadas e o
/// gabarito renumerado para a nova ordem.
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
        'correta': correta,
        'alternativas': alternativas.map((a) => a.toMap()).toList(),
      };

  factory QuestaoProva.fromMap(Map<String, dynamic> m) => QuestaoProva(
        questaoId: (m['questaoId'] ?? '') as String,
        correta: (m['correta'] ?? 'A') as String,
        alternativas: ((m['alternativas'] ?? []) as List)
            .map((a) => Alternativa.fromMap((a as Map).cast<String, dynamic>()))
            .toList(),
      );
}

/// Uma prova personalizada (ordem e alternativas embaralhadas).
class Variacao {
  final String id;
  final List<QuestaoProva> questoes;
  const Variacao({required this.id, required this.questoes});

  Map<String, dynamic> toMap() => {
        'id': id,
        'ordem': questoes.map((q) => q.toMap()).toList(),
      };

  factory Variacao.fromMap(Map<String, dynamic> m) => Variacao(
        id: (m['id'] ?? '') as String,
        questoes: ((m['ordem'] ?? []) as List)
            .map((q) => QuestaoProva.fromMap((q as Map).cast<String, dynamic>()))
            .toList(),
      );
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
  final String professorId;
  final List<Variacao> variacoesDados;
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
    required this.professorId,
    required this.variacoesDados,
  });

  Prova copyWith({
    String? titulo,
    String? turmaId,
    String? data,
    String? modo,
    String? status,
    int? corrigidas,
    int? total,
  }) =>
      Prova(
        id: id,
        titulo: titulo ?? this.titulo,
        turmaId: turmaId ?? this.turmaId,
        data: data ?? this.data,
        questoes: questoes,
        variacoes: variacoes,
        modo: modo ?? this.modo,
        status: status ?? this.status,
        corrigidas: corrigidas ?? this.corrigidas,
        total: total ?? this.total,
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
  final String alunoNome;
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
    this.alunoNome = '',
  });
}
