import 'package:flutter/material.dart';

import '../mock_data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets.dart';

class QuestoesScreen extends StatefulWidget {
  const QuestoesScreen({super.key});
  @override
  State<QuestoesScreen> createState() => _QuestoesScreenState();
}

class _QuestoesScreenState extends State<QuestoesScreen> {
  String _busca = '';
  String _assunto = 'Todos';
  final _stream = FirestoreService.instance.questoesStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Questao>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Erro ao carregar: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final todas = snap.data!;
        final assuntos = <String>[
          'Todos',
          ...{...todas.map((q) => q.assunto)}
        ];
        if (!assuntos.contains(_assunto)) _assunto = 'Todos';
        final lista = todas.where((q) {
          final okAssunto = _assunto == 'Todos' || q.assunto == _assunto;
          final okBusca =
              q.enunciado.toLowerCase().contains(_busca.toLowerCase());
          return okAssunto && okBusca;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageHeader(
              title: 'Banco de questões',
              description:
                  'Questões salvas no Firebase, com gabarito. Toque no lápis para editar ou na lixeira para excluir.',
              action: FilledButton.icon(
                onPressed: () => _abrirFormulario(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova questão'),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por enunciado',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _busca = v),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: assuntos.map((a) {
                final ativo = a == _assunto;
                final estilo = const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8);
                return ativo
                    ? FilledButton(
                        style: FilledButton.styleFrom(
                          padding: estilo,
                          backgroundColor: AppColors.primary,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () => setState(() => _assunto = a),
                        child: Text(a),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: estilo,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () => setState(() => _assunto = a),
                        child: Text(a),
                      );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Text('Nenhuma questão encontrada.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ...lista.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  StatusBadge(q.disciplina,
                                      color: AppColors.muted),
                                  StatusBadge(q.assunto),
                                  Text(q.dificuldade,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () =>
                                  _abrirFormulario(context, questao: q),
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () => _excluir(context, q),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(q.enunciado,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        ...q.alternativas.map((a) {
                          final correta = a.letra == q.correta;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: correta
                                  ? AppColors.success.withOpacity(0.10)
                                  : Colors.transparent,
                              border: Border.all(
                                  color: correta
                                      ? AppColors.success.withOpacity(0.4)
                                      : AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.letra,
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.muted)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(a.texto)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _excluir(BuildContext context, Questao q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir questão'),
        content: const Text('Tem certeza que deseja excluir esta questão?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await FirestoreService.instance.deleteQuestao(q.id);
      if (context.mounted) toast(context, 'Questão excluída.');
    }
  }

  Future<void> _abrirFormulario(BuildContext context,
      {Questao? questao}) async {
    const letras = ['A', 'B', 'C', 'D'];
    final enunciado = TextEditingController(text: questao?.enunciado ?? '');
    final disciplina =
        TextEditingController(text: questao?.disciplina ?? 'Física');
    final assunto = TextEditingController(text: questao?.assunto ?? '');
    final alts = List.generate(4, (i) {
      final existente = questao?.alternativas
          .where((a) => a.letra == letras[i])
          .map((a) => a.texto);
      return TextEditingController(
          text: (existente != null && existente.isNotEmpty)
              ? existente.first
              : '');
    });
    var dificuldade = questao?.dificuldade ?? 'Fácil';
    var correta = questao?.correta ?? 'A';
    final formKey = GlobalKey<FormState>();
    String? obrigatorio(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(questao == null ? 'Nova questão' : 'Editar questão'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: enunciado,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Enunciado'),
                      validator: obrigatorio,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: disciplina,
                      decoration:
                          const InputDecoration(labelText: 'Disciplina'),
                      validator: obrigatorio,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: assunto,
                      decoration: const InputDecoration(labelText: 'Assunto'),
                      validator: obrigatorio,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: dificuldade,
                      decoration:
                          const InputDecoration(labelText: 'Dificuldade'),
                      items: const ['Fácil', 'Média', 'Difícil']
                          .map((d) =>
                              DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => dificuldade = v ?? dificuldade),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < 4; i++) ...[
                      TextFormField(
                        controller: alts[i],
                        decoration: InputDecoration(
                            labelText: 'Alternativa ${letras[i]}'),
                        validator: obrigatorio,
                      ),
                      const SizedBox(height: 8),
                    ],
                    DropdownButtonFormField<String>(
                      value: correta,
                      decoration: const InputDecoration(
                          labelText: 'Alternativa correta (gabarito)'),
                      items: letras
                          .map((l) =>
                              DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setState(() => correta = v ?? correta),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(c, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (salvar != true) return;
    final nova = Questao(
      id: questao?.id ?? '',
      enunciado: enunciado.text.trim(),
      disciplina: disciplina.text.trim(),
      assunto: assunto.text.trim(),
      dificuldade: dificuldade,
      alternativas: [
        for (var i = 0; i < 4; i++) Alternativa(letras[i], alts[i].text.trim())
      ],
      correta: correta,
      usos: questao?.usos ?? 0,
    );
    final s = FirestoreService.instance;
    if (questao == null) {
      await s.addQuestao(nova);
    } else {
      await s.updateQuestao(nova);
    }
    if (context.mounted) {
      toast(context,
          questao == null ? 'Questão cadastrada.' : 'Questão atualizada.');
    }
  }
}
