import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Cadastro e login do professor (requisitos 1 e 2 da N3).
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get mudancas => _auth.authStateChanges();

  User? get usuarioAtual => _auth.currentUser;
  String get uid => _auth.currentUser?.uid ?? '';
  String get email => _auth.currentUser?.email ?? '';

  /// Cria a conta do professor e grava o perfil em "professores".
  Future<void> criarConta({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final uid = cred.user!.uid;
    await cred.user!.updateDisplayName(nome.trim());
    await _db.collection('professores').doc(uid).set({
      'nome': nome.trim(),
      'email': email.trim(),
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> entrar({required String email, required String senha}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);

  Future<void> sair() => _auth.signOut();

  /// Nome do professor logado, para o cabeçalho do app.
  Future<String> nomeProfessor() async {
    final u = _auth.currentUser;
    if (u == null) return 'Professor';
    final doc = await _db.collection('professores').doc(u.uid).get();
    final nome = ((doc.data()?['nome'] ?? '') as String).trim();
    if (nome.isNotEmpty) return nome;
    return (u.displayName ?? '').trim().isEmpty ? 'Professor' : u.displayName!;
  }

  /// Traduz o erro do Firebase para uma frase que o professor entende.
  String mensagemErro(Object erro) {
    if (erro is FirebaseAuthException) {
      switch (erro.code) {
        case 'weak-password':
          return 'Senha muito fraca: use pelo menos 6 caracteres.';
        case 'email-already-in-use':
          return 'Este e-mail já tem conta. Faça login.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-not-found':
          return 'Nenhuma conta com este e-mail.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'too-many-requests':
          return 'Muitas tentativas seguidas. Aguarde um pouco.';
        case 'network-request-failed':
          return 'Sem conexão com a internet.';
        case 'operation-not-allowed':
          return 'Ative "E-mail/senha" no console do Firebase: '
              'Authentication → Sign-in method → Email/Password → Ativar.';
        default:
          return erro.message ?? 'Não foi possível autenticar.';
      }
    }
    return erro.toString();
  }
}
