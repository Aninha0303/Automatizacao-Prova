import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

/// Fluxo de correção pela câmera.
/// No Android/iOS usa a câmera real (mobile_scanner) para ler o QR da folha.
/// Na web/desktop mostra um placeholder com leitura simulada.
class CorrecaoScreen extends StatefulWidget {
  const CorrecaoScreen({super.key});
  @override
  State<CorrecaoScreen> createState() => _CorrecaoScreenState();
}

class _CorrecaoScreenState extends State<CorrecaoScreen> {
  bool _lendo = false;
  String? _ultimoCodigo;

  bool get _cameraDisponivel =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _registrarLeitura(String codigo) {
    if (codigo == _ultimoCodigo) return;
    _ultimoCodigo = codigo;
    // QR no formato provaId|variacao|matricula
    final partes = codigo.split('|');
    final matricula = partes.length > 2 ? partes[2] : '';
    final aluno = alunos.where((a) => a.matricula == matricula).toList();
    final base = correcoes[_lidas.length % correcoes.length];
    final c = aluno.isEmpty
        ? base
        : Correcao(
            id: codigo,
            alunoId: aluno.first.id,
            provaId: partes[0],
            variacao: partes.length > 1 ? partes[1] : base.variacao,
            acertos: base.acertos,
            total: base.total,
            nota: base.nota,
            lidaEm: 'agora',
            respostas: base.respostas,
          );
    setState(() => _lidas.insert(0, c));
    toast(context, 'Folha de ${nomeAluno(c.alunoId)} corrigida.');
  }
  final List<Correcao> _lidas = [];

  Future<void> _simularLeitura() async {
    setState(() => _lendo = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final proxima = correcoes[_lidas.length % correcoes.length];
    setState(() {
      _lendo = false;
      _lidas.insert(0, proxima);
    });
    toast(context, 'Folha de ${nomeAluno(proxima.alunoId)} corrigida.');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageHeader(
          title: 'Correção',
          description:
              'Aponte a câmera para o QR code da folha; a leitura identifica o aluno e a variação.',
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
                                      style: TextStyle(color: Colors.white70),
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
        SectionCard(
          title: 'Folhas corrigidas nesta sessão',
          child: _lidas.isEmpty
              ? Text('Nenhuma folha lida ainda.',
                  style: Theme.of(context).textTheme.bodySmall)
              : Column(
                  children: _lidas
                      .map((c) => ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(nomeAluno(c.alunoId)),
                            subtitle: Text(
                                '${c.variacao} · ${c.acertos}/${c.total} acertos'),
                            trailing: StatusBadge(
                              c.nota.toStringAsFixed(1),
                              color: c.nota >= 6
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            children: c.respostas
                                .map((r) => ListTile(
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
                                      title: Text('Questão ${r.questao}'),
                                      trailing: Text(
                                          'marcou ${r.marcada} · correta ${r.correta}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ))
                                .toList(),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
