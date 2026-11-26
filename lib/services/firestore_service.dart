import 'package:cloud_firestore/cloud_firestore.dart';

import '../models.dart';

/// Camada de acesso ao Firestore (N3).
/// Tudo é do professor logado — nada de dados de exemplo.
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  /// Definido assim que o professor entra; todas as consultas filtram por ele.
  String professorId = '';
  void setProfessor(String uid) => professorId = uid;

  CollectionReference<Map<String, dynamic>> get _turmas =>
      _db.collection('turmas');
  CollectionReference<Map<String, dynamic>> get _alunos =>
      _db.collection('alunos');
  CollectionReference<Map<String, dynamic>> get _questoes =>
      _db.collection('questoes');
  CollectionReference<Map<String, dynamic>> get _provas =>
      _db.collection('provas');
  CollectionReference<Map<String, dynamic>> get _correcoes =>
      _db.collection('correcoes');

  // ---------- TURMAS ----------
  Turma _turmaDoMapa(String id, Map<String, dynamic> m) => Turma(
        id: id,
        nome: (m['nome'] ?? '') as String,
        disciplina: (m['disciplina'] ?? '') as String,
      );

  Stream<List<Turma>> turmasStream() => _turmas
      .where('professorId', isEqualTo: professorId)
      .snapshots()
      .map((s) => s.docs.map((d) => _turmaDoMapa(d.id, d.data())).toList()
        ..sort((a, b) => a.nome.compareTo(b.nome)));

  Future<void> addTurma(String nome, String disciplina) => _turmas.add({
        'nome': nome.trim(),
        'disciplina': disciplina.trim(),
        'professorId': professorId,
        'criadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> updateTurma(String id, String nome, String disciplina) =>
      _turmas.doc(id).update({
        'nome': nome.trim(),
        'disciplina': disciplina.trim(),
      });

  Future<void> deleteTurma(String id) => _turmas.doc(id).delete();

  // ---------- ALUNOS ----------
  Aluno _alunoDoMapa(String id, Map<String, dynamic> m) => Aluno(
        id: id,
        nome: (m['nome'] ?? '') as String,
        matricula: (m['matricula'] ?? '') as String,
        turmaId: (m['turmaId'] ?? '') as String,
      );

  Stream<List<Aluno>> alunosStream() => _alunos
      .where('professorId', isEqualTo: professorId)
      .snapshots()
      .map((s) => s.docs.map((d) => _alunoDoMapa(d.id, d.data())).toList()
        ..sort((a, b) => a.nome.compareTo(b.nome)));

  Stream<Map<String, String>> nomesAlunosStream() => alunosStream()
      .map((lista) => {for (final a in lista) a.id: a.nome});

  Future<void> addAluno(String nome, String matricula, String turmaId) =>
      _alunos.add({
        'nome': nome.trim(),
        'matricula': matricula.trim(),
        'turmaId': turmaId,
        'professorId': professorId,
        'criadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> updateAluno(
          String id, String nome, String matricula, String turmaId) =>
      _alunos.doc(id).update({
        'nome': nome.trim(),
        'matricula': matricula.trim(),
        'turmaId': turmaId,
      });

  Future<void> deleteAluno(String id) => _alunos.doc(id).delete();

  // ---------- QUESTÕES ----------
  Map<String, dynamic> _questaoParaMapa(Questao q) => {
        'enunciado': q.enunciado,
        'disciplina': q.disciplina,
        'assunto': q.assunto,
        'dificuldade': q.dificuldade,
        'alternativas':
            q.alternativas.map((a) => a.toMap()).toList(),
        'correta': q.correta,
        'usos': q.usos,
        'professorId': professorId,
      };

  Questao _questaoDoMapa(String id, Map<String, dynamic> m) => Questao(
        id: id,
        enunciado: (m['enunciado'] ?? '') as String,
        disciplina: (m['disciplina'] ?? '') as String,
        assunto: (m['assunto'] ?? '') as String,
        dificuldade: (m['dificuldade'] ?? 'Fácil') as String,
        alternativas: ((m['alternativas'] ?? []) as List)
            .map((a) => Alternativa.fromMap((a as Map).cast<String, dynamic>()))
            .toList(),
        correta: (m['correta'] ?? 'A') as String,
        usos: ((m['usos'] ?? 0) as num).toInt(),
      );

  Stream<List<Questao>> questoesStream() => _questoes
      .where('professorId', isEqualTo: professorId)
      .snapshots()
      .map((s) => s.docs.map((d) => _questaoDoMapa(d.id, d.data())).toList()
        ..sort((a, b) => a.enunciado.compareTo(b.enunciado)));

  Future<void> addQuestao(Questao q) => _questoes.add(_questaoParaMapa(q));

  Future<void> updateQuestao(Questao q) =>
      _questoes.doc(q.id).update(_questaoParaMapa(q));

  Future<void> deleteQuestao(String id) => _questoes.doc(id).delete();

  // ---------- PROVAS ----------
  Map<String, dynamic> _provaParaMapa(Prova p) => {
        'titulo': p.titulo,
        'turmaId': p.turmaId,
        'data': p.data,
        'questoes': p.questoes,
        'variacoes': p.variacoes,
        'modo': p.modo,
        'status': p.status,
        'corrigidas': p.corrigidas,
        'total': p.total,
        'professorId': p.professorId,
        'variacoesDados': p.variacoesDados.map((v) => v.toMap()).toList(),
      };

  Prova _provaDoMapa(String id, Map<String, dynamic> m) => Prova(
        id: id,
        titulo: (m['titulo'] ?? '') as String,
        turmaId: (m['turmaId'] ?? '') as String,
        data: (m['data'] ?? '') as String,
        questoes: ((m['questoes'] ?? 0) as num).toInt(),
        variacoes: ((m['variacoes'] ?? 0) as num).toInt(),
        modo: (m['modo'] ?? '') as String,
        status: (m['status'] ?? 'Rascunho') as String,
        corrigidas: ((m['corrigidas'] ?? 0) as num).toInt(),
        total: ((m['total'] ?? 0) as num).toInt(),
        professorId: (m['professorId'] ?? '') as String,
        variacoesDados: ((m['variacoesDados'] ?? []) as List)
            .map((v) => Variacao.fromMap((v as Map).cast<String, dynamic>()))
            .toList(),
      );

  Stream<List<Prova>> provasStream() => _provas
      .where('professorId', isEqualTo: professorId)
      .snapshots()
      .map((s) => s.docs.map((d) => _provaDoMapa(d.id, d.data())).toList()
        ..sort((a, b) => b.titulo.compareTo(a.titulo)));

  /// Lê uma prova pelo id, conferindo se é do professor logado.
  Future<Prova?> provaPorId(String id) async {
    final doc = await _provas.doc(id).get();
    if (!doc.exists) return null;
    final p = _provaDoMapa(doc.id, doc.data()!);
    return p.professorId == professorId ? p : null;
  }

  Future<void> addProva(Prova p) => _provas.add({
        ..._provaParaMapa(p),
        'criadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> updateProva(Prova p) =>
      _provas.doc(p.id).update(_provaParaMapa(p));

  Future<void> deleteProva(String id) => _provas.doc(id).delete();

  /// Incrementa as folhas corrigidas e atualiza o status da prova.
  /// Quando todas as folhas forem corrigidas, a prova vira "Corrigida".
  Future<void> registrarFolhaCorrigida(String provaId) async {
    final ref = _provas.doc(provaId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final atual = ((doc.data()?['corrigidas'] ?? 0) as num).toInt();
    final total = ((doc.data()?['total'] ?? 0) as num).toInt();
    final novo = atual + 1;
    await ref.update({
      'corrigidas': novo,
      'status': (total > 0 && novo >= total) ? 'Corrigida' : 'Aplicada',
    });
  }

  // ---------- CORREÇÕES ----------
  Map<String, dynamic> _correcaoParaMapa(Correcao c, String alunoNome) => {
        'alunoId': c.alunoId,
        'alunoNome': alunoNome,
        'provaId': c.provaId,
        'variacao': c.variacao,
        'acertos': c.acertos,
        'total': c.total,
        'nota': c.nota,
        'lidaEm': c.lidaEm,
        'professorId': professorId,
        'respostas': c.respostas
            .map((r) => {
                  'questao': r.questao,
                  'marcada': r.marcada,
                  'correta': r.correta,
                })
            .toList(),
      };

  Correcao _correcaoDoMapa(String id, Map<String, dynamic> m) => Correcao(
        id: id,
        alunoId: (m['alunoId'] ?? '') as String,
        provaId: (m['provaId'] ?? '') as String,
        variacao: (m['variacao'] ?? '') as String,
        acertos: ((m['acertos'] ?? 0) as num).toInt(),
        total: ((m['total'] ?? 0) as num).toInt(),
        nota: ((m['nota'] ?? 0) as num).toDouble(),
        lidaEm: (m['lidaEm'] ?? '') as String,
        respostas: ((m['respostas'] ?? []) as List)
            .map((r) => Resposta(
                  ((r['questao'] ?? 0) as num).toInt(),
                  (r['marcada'] ?? '') as String,
                  (r['correta'] ?? '') as String,
                ))
            .toList(),
      );

  Stream<List<Correcao>> _ordenar(Stream<List<Correcao>> base) =>
      base.map((lista) => lista..sort((a, b) => b.lidaEm.compareTo(a.lidaEm)));

  Stream<List<Correcao>> correcoesStream() => _ordenar(_correcoes
      .where('professorId', isEqualTo: professorId)
      .snapshots()
      .map((s) => s.docs.map((d) => _correcaoDoMapa(d.id, d.data())).toList()));

  /// Correções de uma prova específica (relatório por prova).
  Stream<List<Correcao>> correcoesDaProvaStream(String provaId) =>
      _ordenar(_correcoes
          .where('professorId', isEqualTo: professorId)
          .where('provaId', isEqualTo: provaId)
          .snapshots()
          .map((s) =>
              s.docs.map((d) => _correcaoDoMapa(d.id, d.data())).toList()));

  Future<void> addCorrecao(Correcao c, String alunoNome) =>
      _correcoes.add(_correcaoParaMapa(c, alunoNome));

  Future<void> deleteCorrecao(String id) => _correcoes.doc(id).delete();

  /// Evita corrigir a mesma folha duas vezes.
  Future<bool> correcaoExistente(String provaId, String alunoId) async {
    final s = await _correcoes
        .where('professorId', isEqualTo: professorId)
        .where('provaId', isEqualTo: provaId)
        .where('alunoId', isEqualTo: alunoId)
        .limit(1)
        .get();
    return s.docs.isNotEmpty;
  }
}
