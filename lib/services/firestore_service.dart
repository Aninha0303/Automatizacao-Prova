import 'package:cloud_firestore/cloud_firestore.dart';

import '../mock_data.dart';

/// Camada de acesso ao Firestore (N2) — substitui aos poucos o mock_data.
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alunos =>
      _db.collection('alunos');

  // ---------- ALUNOS ----------
  Stream<List<Aluno>> alunosStream() => _alunos.orderBy('nome').snapshots().map(
        (s) => s.docs
            .map((d) => Aluno(
                  d.id,
                  d['nome'] as String,
                  d['matricula'] as String,
                  d['turmaId'] as String,
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

  Future<void> updateAluno(String id, Map<String, dynamic> dados) =>
      _alunos.doc(id).update(dados);

  Future<void> deleteAluno(String id) => _alunos.doc(id).delete();

  /// Envia os alunos do mock para o banco uma única vez (se estiver vazio).
  Future<void> seedSeVazio() async {
    final snap = await _alunos.limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final batch = _db.batch();
    for (final a in alunos) {
      batch.set(_alunos.doc(a.id), {
        'nome': a.nome,
        'matricula': a.matricula,
        'turmaId': a.turmaId,
      });
    }
    await batch.commit();
  }
}
