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
    if (temAlgo) await batch.commit();
  }
}
