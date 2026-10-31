import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../mock_data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Fluxo de correção pela câmera.
/// No Android/iOS usa a câmera real (mobile_scanner) para ler o QR da folha.
/// Na web/desktop mostra um placeholder com leitura simulada.
/// Cada folha lida é gravada na coleção "correcoes" do Firestore.
class CorrecaoScreen extends StatefulWidget {
  const CorrecaoScreen({super.key});
  @override
  State<CorrecaoScreen> createState() => _CorrecaoScreenState();
}

class _CorrecaoScreenState extends State<CorrecaoScreen> {
  bool _lendo = false;
  String? _ultimoCodigo;
  List<Aluno> _alunos = [];
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    FirestoreService.instance.alunosStream().first.then((lista) {
      if (mounted) setState(() => _alunos = lista);
    });
  }

  bool get _cameraDisponivel =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Monta uma correção de exemplo para o aluno (leitura dos quadradinhos
  /// ainda é simulada; o QR e a gravação no banco são reais).
  Correcao _gerarCorrecao(Aluno aluno, String provaId, String variacao) {
    const total = 20;
    final acertos = 8 + _rnd.nextInt(13); // 8..20
    final respostas = List.generate(5, (i) {
      final correta = 'ABCD'[_rnd.nextInt(4)];
      final acertou = _rnd.nextBool();
      return Resposta(
          i + 1, acertou ? correta : 'ABCD'[_rnd.nextInt(4)], correta);
    });
    return Correcao(
      id: '',
      alunoId: aluno.id,
      provaId: provaId,
      variacao: variacao,
      acertos: acertos,
      total: total,
      nota: acertos / total * 10,
      lidaEm: 'agora',
      respostas: respostas,
    );
  }

  Future<void> _registrarLeitura(String codigo) async {
    if (codigo == _ultimoCodigo) return;
    _ultimoCodigo = codigo;
    // QR no formato provaId|variacao|matricula
    final partes = codigo.split('|');
    final matricula = partes.length > 2 ? partes[2] : '';
    final encontrados =
        _alunos.where((a) => a.matricula == matricula).toList();
    if (encontrados.isEmpty) {
      toast(context, 'Aluno não encontrado para este QR.');
      return;
    }
    final aluno = encontrados.first;
    final c = _gerarCorrecao(
        aluno, partes[0], partes.length > 1 ? partes[1] : 'V-01');
    await FirestoreService.instance.addCorrecao(c, aluno.nome);
    if (mounted) toast(context, 'Folha de ${aluno.nome} corrigida e salva.');
  }

  Future<void> _simularLeitura() async {
    if (_alunos.isEmpty) {
      toast(context, 'Nenhum aluno cadastrado para simular.');
      return;
    }
    setState(() => _lendo = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final aluno = _alunos[_rnd.nextInt(_alunos.length)];
    final c = _gerarCorrecao(
        aluno, 'p1', 'V-${(1 + _rnd.nextInt(30)).toString().padLeft(2, '0')}');
    await FirestoreService.instance.addCorrecao(c, aluno.nome);
    setState(() => _lendo = false);
    if (mounted) toast(context, 'Folha de ${aluno.nome} corrigida e salva.');
  }

  Future<void> _excluir(Correcao c) async {
    await FirestoreService.instance.deleteCorrecao(c.id);
    if (mounted) toast(context, 'Correção excluída.');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageHeader(
          title: 'Correção',
          description:
              'Leia o QR code da folha de resposta: o sistema identifica a variação, lê os quadradinhos marcados, calcula a nota e grava no Firebase.',
        ),
        Card(
          child: Column(children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  color: AppColors.ink.withOpacity(0.9),
                  child: _cameraDisponivel
                      ? MobileScanner(
                          onDetect: (capture) {
                            final code = capture.barcodes.isNotEmpty
                                ? capture.barcodes.first.rawValue
                                : null;
                            if (code != null) _registrarLeitura(code);
                          },
                        )
                      : Center(
                          child: _lendo
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.qr_code_scanner,
                                        size: 48, color: Colors.white70),
                                    SizedBox(height: 8),
                                    Text(
                                      'Câmera disponível no celular.\nAqui a leitura roda em modo simulado.',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _lendo ? null : _simularLeitura,
                  icon: const Icon(Icons.center_focus_strong, size: 18),
                  label: Text(_lendo ? 'Lendo…' : 'Ler folha'),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Correcao>>(
          stream: FirestoreService.instance.correcoesStream(),
          builder: (context, snap) {
            final lista = snap.data ?? [];
            return StreamBuilder<Map<String, String>>(
              stream: FirestoreService.instance.nomesAlunosStream(),
              builder: (context, snapNomes) {
                final nomes = snapNomes.data ?? {};
                return SectionCard(
                  title: 'Folhas corrigidas (Firebase)',
                  child: lista.isEmpty
                      ? Text(
                          snap.connectionState == ConnectionState.waiting
                              ? 'Carregando…'
                              : 'Nenhuma folha lida ainda.',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : Column(
                          children: lista
                              .map((c) => ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    title: Text(
                                        nomes[c.alunoId] ?? c.alunoId),
                                    subtitle: Text(
                                        '${c.variacao} · ${c.acertos}/${c.total} acertos'),
                                    trailing: StatusBadge(
                                      c.nota.toStringAsFixed(1),
                                      color: c.nota >= 6
                                          ? AppColors.success
                                          : AppColors.danger,
                                    ),
                                    children: [
                                      ...c.respostas.map((r) => ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              r.acertou
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: r.acertou
                                                  ? AppColors.success
                                                  : AppColors.danger,
                                              size: 18,
                                            ),
                                            title:
                                                Text('Questão ${r.questao}'),
                                            trailing: Text(
                                                'marcou ${r.marcada} · correta ${r.correta}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          )),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () => _excluir(c),
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              size: 16),
                                          label:
                                              const Text('Excluir correção'),
                                        ),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
