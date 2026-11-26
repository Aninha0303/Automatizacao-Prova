import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets.dart';

/// Cadastro de conta de professor (requisito 1 da N3).
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _carregando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v, String aviso) =>
      (v == null || v.trim().isEmpty) ? aviso : null;

  String? _validarEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Informe o e-mail';
    if (!t.contains('@') || !t.contains('.')) return 'E-mail inválido';
    return null;
  }

  String? _validarSenha(String? v) {
    final t = v ?? '';
    if (t.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  String? _validarConfirma(String? v) =>
      (v ?? '') != _senha.text ? 'As senhas não conferem' : null;

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate() || _carregando) return;
    setState(() => _carregando = true);
    try {
      await AuthService.instance.criarConta(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
      );
      // A conta já entra logada; o stream de auth troca a tela no main.dart.
    } catch (e) {
      if (mounted) toast(context, AuthService.instance.mensagemErro(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Dados do professor',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('A conta guarda as suas turmas, questões e provas.',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nome,
                      decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => _obrigatorio(v, 'Informe o nome'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofilter: false,
                      decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.mail_outline)),
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senha,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline),
                          helperText: 'Pelo menos 6 caracteres'),
                      validator: _validarSenha,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirma,
                      obscureText: true,
                      onFieldSubmitted: (_) => _criar(),
                      decoration: const InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: Icon(Icons.lock_reset_outlined)),
                      validator: _validarConfirma,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _carregando ? null : _criar,
                      icon: _carregando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(_carregando ? 'Criando…' : 'Criar conta'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _carregando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Já tenho conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
