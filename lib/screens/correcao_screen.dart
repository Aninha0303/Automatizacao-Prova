import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models.dart';
import '../qr_link.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

/// Correção real: o QR identifica a folha (prova, variação e matrícula),
/// a tela mostra a variação daquele aluno e a nota é calculada comparando
/// as marcas com o gabarito salvo da variação.
class CorrecaoScreen extends StatefulWidget {
  /// Código vindo do link do QR (câmera do iPhone abre o app já na folha).
  final String? codigoInicial;
  const CorrecaoScreen({super.key, this.codigoInicial});
  @override
  State<CorrecaoScreen> createState() => _CorrecaoScreenState();
}

class _CorrecaoScreenState extends State<CorrecaoScreen> {
  final _codigo = TextEditingController();
  List<Aluno> _alunos = [];
  String? _ultimoCodigo;
  bool _ocupado = false;
  // No celular instalado a câmera já começa ligada; no navegador ela liga
  // ao tocar no botão (o Safari só libera a câmera depois de um toque).
  bool _cameraLigada = !kIsWeb;

  @override
  void initState() {
    super.initState();
    FirestoreService.instance.alunosStream().first.then((lista) {
      if (mounted) setState(() => _alunos = lista);
    });
    final inicial = widget.codigoInicial;
    if (inicial != null && inicial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _registrarLeitura(inicial);
      });
    }
  }

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _registrarLeitura(String lido) async {
    if (_ocupado) return;
    final codigo = extrairCodigoDaFolha(lido);
    if (codigo == _ultimoCodigo) return;
    _ultimoCodigo = codigo;

    final partes = codigo.split('|');
    if (partes.length < 3) {
      if (mounted) {
        toast(context, 'QR fora do padrão prova|variação|matrícula.');
      }
      return;
    }

    setState(() => _ocupado = true);
    try {
      final s = FirestoreService.instance;
      final prova = await s.provaPorId(partes[0]);
      if (prova == null) {
        if (mounted) toast(context, 'Prova não encontrada para este QR.');
        return;
      }

      final variacoes = prova.variacoesDados
          .where((v) => v.id == partes[1])
          .toList();
      if (variacoes.isEmpty) {
        if (mounted) {
          toast(context, 'Variação "${partes[1]}" não existe nesta prova.');
        }
        return;
      }

      final alunos = _alunos.isEmpty
          ? await s.alunosStream().first
          : _alunos;
      final encontrados =
          alunos.where((a) => a.matricula == partes[2]).toList();
      if (encontrados.isEmpty) {
        if (mounted) {
          toast(context, 'Nenhum aluno com a matrícula ${partes[2]}.');
        }
        return;
      }

      final aluno = encontrados.first;
      if (await s.correcaoExistente(prova.id, aluno.id)) {
        if (mounted) {
          toast(context, 'A folha de ${aluno.nome} já foi corrigida.');
        }
        return;
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FolhaCorrecaoScreen(
            prova: prova,
            variacao: variacoes.first,
            aluno: aluno,
          ),
        ),
      );
    } catch (e) {
      if (mounted) toast(context, 'Erro ao abrir a folha: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
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
              'Leia o QR da folha: o sistema abre a variação do aluno, você '
              'marca o que ele respondeu e a nota sai do gabarito salvo.',
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
                  child: _cameraLigada
                      ? MobileScanner(
                          onDetect: (capture) {
                            final code = capture.barcodes.isNotEmpty
                                ? capture.barcodes.first.rawValue
                                : null;
                            if (code != null) _registrarLeitura(code);
                          },
                          errorBuilder: (context, erro, child) => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Não foi possível abrir a câmera.\n'
                                'Permita o acesso à câmera e use o endereço '
                                'https do app.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.qr_code_scanner,
                                  size: 48, color: Colors.white70),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () =>
                                    setState(() => _cameraLigada = true),
                                icon: const Icon(Icons.photo_camera, size: 18),
                                label: const Text('Ler QR com a câmera'),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _codigo,
                    enabled: !_ocupado,
                    decoration: const InputDecoration(
                      labelText: 'Ou digite o código da folha (opcional)',
                      hintText: 'provaId|V-01|2024001',
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _registrarLeitura(v.trim());
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _ocupado
                          ? null
                          : () {
                              final v = _codigo.text.trim();
                              if (v.isEmpty) {
                                toast(context,
                                    'Leia o QR com a câmera ou digite o código da folha.');
                              } else {
                                _registrarLeitura(v);
                              }
                            },
                      icon: const Icon(Icons.center_focus_strong, size: 18),
                      label: Text(_ocupado ? 'Lendo…' : 'Abrir esta folha'),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Correcao>>(
          stream: FirestoreService.instance.correcoesStream(),
          builder: (context, snap) {
            final lista = snap.data ?? [];
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
                                    c.alunoNome.isEmpty
                                        ? c.alunoId
                                        : c.alunoNome),
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
                                            'marcou ${r.marcada} · correta '
                                            '${r.correta}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      )),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _excluir(c),
                                      icon: const Icon(Icons.delete_outline,
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
        ),
      ],
    );
  }
}

/// Tela aberta pelo QR: mostra a variação do aluno, o professor marca o que
/// foi respondido e a nota é calculada contra o gabarito salvo.
class FolhaCorrecaoScreen extends StatefulWidget {
  final Prova prova;
  final Variacao variacao;
  final Aluno aluno;
  const FolhaCorrecaoScreen({
    super.key,
    required this.prova,
    required this.variacao,
    required this.aluno,
  });
  @override
  State<FolhaCorrecaoScreen> createState() => _FolhaCorrecaoScreenState();
}

class _FolhaCorrecaoScreenState extends State<FolhaCorrecaoScreen> {
  final Map<int, String> _marcadas = {};
  Map<String, Questao> _banco = {};
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    FirestoreService.instance.questoesStream().first.then((qs) {
      if (!mounted) return;
      setState(() {
        _banco = {for (final q in qs) q.id: q};
        _carregando = false;
      });
    });
  }

  Future<void> _salvar() async {
    final total = widget.variacao.questoes.length;
    final faltando = <int>[];
    for (var i = 0; i < total; i++) {
      if ((_marcadas[i] ?? '').isEmpty) faltando.add(i + 1);
    }
    if (faltando.isNotEmpty) {
      toast(context, 'Marque as questões: ${faltando.join(', ')}.');
      return;
    }

    setState(() => _salvando = true);
    final respostas = <Resposta>[];
    var acertos = 0;
    for (var i = 0; i < total; i++) {
      final qp = widget.variacao.questoes[i];
      final marcada = _marcadas[i] ?? '';
      if (marcada == qp.correta) acertos++;
      respostas.add(Resposta(i + 1, marcada, qp.correta));
    }
    final nota = total == 0 ? 0.0 : acertos / total * 10;

    final correcao = Correcao(
      id: '',
      alunoId: widget.aluno.id,
      provaId: widget.prova.id,
      variacao: widget.variacao.id,
      acertos: acertos,
      total: total,
      nota: nota,
      lidaEm: DateTime.now().toIso8601String(),
      respostas: respostas,
    );

    try {
      await FirestoreService.instance
          .addCorrecao(correcao, widget.aluno.nome);
      await FirestoreService.instance
          .registrarFolhaCorrigida(widget.prova.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Nota de ${widget.aluno.nome}'),
          content: Text(
              '${acertos} acertos em ${total} questões.\n'
              'Nota: ${nota.toStringAsFixed(1)}\n\n'
              'A folha foi salva no Firebase e a prova foi atualizada.'),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Fechar')),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) toast(context, 'Erro ao salvar a correção: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.variacao;
    return Scaffold(
      appBar: AppBar(title: Text('Folha de ${widget.aluno.nome}')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: widget.prova.titulo,
                  description:
                      'Matrícula ${widget.aluno.matricula} · ${v.id} · '
                      '${v.questoes.length} questões. Marque a alternativa '
                      'que o aluno respondeu.',
                ),
                for (var i = 0; i < v.questoes.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}. '
                              '${_banco[v.questoes[i].questaoId]?.enunciado ?? 'Questão'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: v.questoes[i].alternativas
                                .map((a) => ChoiceChip(
                                      label: Text('${a.letra}) ${a.texto}'),
                                      selected: (_marcadas[i] ?? '') == a.letra,
                                      onSelected: (_) =>
                                          setState(() => _marcadas[i] =
                                              a.letra),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(_salvando
                        ? 'Salvando…'
                        : 'Corrigir e salvar nota'),
                  ),
                ),
              ],
            ),
    );
  }
}
