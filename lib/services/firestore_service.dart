import 'package:cloud_firestore/cloud_firestore.dart';

import '../mock_data.dart';

/// Camada de acesso ao Firestore (N2) — substitui o mock_data.
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alunos =>
      _db.collection('alunos');
  CollectionReference<Map<String, dynamic>> get _questoes =>
      _db.collection('questoes');
  CollectionReference<Map<String, dynamic>> get _provas =>
      _db.collection('provas');
  CollectionReference<Map<String, dynamic>> get _correcoes =>
      _db.collection('correcoes');

  // ---------- ALUNOS ----------
  Stream<List<Aluno>> alunosStream() =>
      _alunos.orderBy('nome').snapshots().map(
            (s) => s.docs
                .map((d) => Aluno(
                      d.id,
                      (d.data()['nome'] ?? '') as String,
                      (d.data()['matricula'] ?? '') as String,
                      (d.data()['turmaId'] ?? 't1') as String,
                    ))
                .toList(),
          );

  /// Mapa id -> nome, útil para telas que só exibem o nome do aluno.
  Stream<Map<String, String>> nomesAlunosStream() => alunosStream()
      .map((lista) => {for (final a in lista) a.id: a.nome});

  Future<void> addAluno(String nome, String matricula, String turmaId) =>
      _alunos.add({
        'nome': nome,
        'matricula': matricula,
        'turmaId': turmaId,
        'criadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> updateAluno(
          String id, String nome, String matricula, String turmaId) =>
      _alunos.doc(id).update({
        'nome': nome,
        'matricula': matricula,
        'turmaId': turmaId,
      });

  Future<void> deleteAluno(String id) => _alunos.doc(id).delete();

  // ---------- QUESTÕES ----------
  Map<String, dynamic> _questaoParaMapa(Questao q) => {
        'enunciado': q.enunciado,
        'disciplina': q.disciplina,
        'assunto': q.assunto,
        'dificuldade': q.dificuldade,
        'alternativas': q.alternativas
            .map((a) => {'letra': a.letra, 'texto': a.texto})
            .toList(),
        'correta': q.correta,
        'usos': q.usos,
      };

  Questao _mapaParaQuestao(String id, Map<String, dynamic> m) => Questao(
        id: id,
        enunciado: (m['enunciado'] ?? '') as String,
        disciplina: (m['disciplina'] ?? '') as String,
        assunto: (m['assunto'] ?? '') as String,
        dificuldade: (m['dificuldade'] ?? 'Fácil') as String,
        alternativas: ((m['alternativas'] ?? []) as List)
            .map((a) => Alternativa(
                (a['letra'] ?? '') as String, (a['texto'] ?? '') as String))
            .toList(),
        correta: (m['correta'] ?? 'A') as String,
        usos: ((m['usos'] ?? 0) as num).toInt(),
      );

  Stream<List<Questao>> questoesStream() => _questoes.snapshots().map(
      (s) => s.docs.map((d) => _mapaParaQuestao(d.id, d.data())).toList());

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
      };

  Prova _mapaParaProva(String id, Map<String, dynamic> m) => Prova(
        id: id,
        titulo: (m['titulo'] ?? '') as String,
        turmaId: (m['turmaId'] ?? 't1') as String,
        data: (m['data'] ?? '') as String,
        questoes: ((m['questoes'] ?? 0) as num).toInt(),
        variacoes: ((m['variacoes'] ?? 0) as num).toInt(),
        modo: (m['modo'] ?? '') as String,
        status: (m['status'] ?? 'Rascunho') as String,
        corrigidas: ((m['corrigidas'] ?? 0) as num).toInt(),
        total: ((m['total'] ?? 0) as num).toInt(),
      );

  Stream<List<Prova>> provasStream() => _provas.snapshots().map(
      (s) => s.docs.map((d) => _mapaParaProva(d.id, d.data())).toList());

  Future<void> addProva(Prova p) => _provas.add({
        ..._provaParaMapa(p),
        'criadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> updateProva(Prova p) =>
      _provas.doc(p.id).update(_provaParaMapa(p));

  Future<void> deleteProva(String id) => _provas.doc(id).delete();

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
        'respostas': c.respostas
            .map((r) => {
                  'questao': r.questao,
                  'marcada': r.marcada,
                  'correta': r.correta,
                })
            .toList(),
      };

  Correcao _mapaParaCorrecao(String id, Map<String, dynamic> m) => Correcao(
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

  Stream<List<Correcao>> correcoesStream() => _correcoes
      .orderBy('criadoEm', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => _mapaParaCorrecao(d.id, d.data())).toList());

  Future<void> addCorrecao(Correcao c, String alunoNome) => _correcoes.add({
        ..._correcaoParaMapa(c, alunoNome),
        'criadoEm': FieldValue.serverTimestamp(),
      });

  Future<void> deleteCorrecao(String id) => _correcoes.doc(id).delete();

  /// Envia os dados de exemplo para o banco uma única vez (se estiver vazio).
  Future<void> seedSeVazio() async {
    final batch = _db.batch();
    var temAlgo = false;

    if ((await _alunos.limit(1).get()).docs.isEmpty) {
      for (final a in alunos) {
        batch.set(_alunos.doc(a.id), {
          'nome': a.nome,
          'matricula': a.matricula,
          'turmaId': a.turmaId,
        });
      }
      temAlgo = true;
    }
    if ((await _questoes.limit(1).get()).docs.isEmpty) {
      for (final q in questoes) {
        batch.set(_questoes.doc(q.id), _questaoParaMapa(q));
      }
      temAlgo = true;
    }
    if ((await _provas.limit(1).get()).docs.isEmpty) {
      for (final p in provas) {
        batch.set(_provas.doc(p.id), {
          ..._provaParaMapa(p),
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
      temAlgo = true;
    }
    if ((await _correcoes.limit(1).get()).docs.isEmpty) {
      for (final c in correcoes) {
        batch.set(_correcoes.doc(c.id), {
          ..._correcaoParaMapa(c, nomeAluno(c.alunoId)),
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
      temAlgo = true;
    }
    if (temAlgo) await batch.commit();
  }
}
