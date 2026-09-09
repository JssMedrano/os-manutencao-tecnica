import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/enums.dart';
import '../core/validators.dart';
import '../models/tecnico.dart';
import '../widgets/empty_hint.dart';
import '../widgets/feedback.dart';

/// CRUD de técnicos. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class TecnicosScreen extends StatelessWidget {
  const TecnicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo técnico'),
      ),
      body: app.tecnicos.isEmpty
          ? const EmptyHint(texto: 'Nenhum técnico cadastrado.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: app.tecnicos.length,
              itemBuilder: (_, i) {
                final t = app.tecnicos[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.engineering)),
                    title: Text(t.nome),
                    subtitle: Text('${t.especialidade} · ${t.contato}\n${t.situacao.label}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _form(context, tecnico: t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await confirmarExclusao(
                              context,
                              titulo: 'Excluir técnico',
                              mensagem: 'Deseja excluir ${t.nome}?',
                            );
                            if (!ok || !context.mounted) return;
                            final erro = await app.facade.tecnicos.excluir(t.id!);
                            if (!context.mounted) return;
                            if (erro != null) {
                              snackErro(context, erro);
                            } else {
                              snackOk(context, 'Técnico excluído.');
                              await app.carregarTudo();
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () => _form(context, tecnico: t),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _form(BuildContext context, {Tecnico? tecnico}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TecnicoFormScreen(tecnico: tecnico)),
    );
    if (context.mounted) await context.read<AppController>().carregarTudo();
  }
}

class TecnicoFormScreen extends StatefulWidget {
  const TecnicoFormScreen({super.key, this.tecnico});
  final Tecnico? tecnico;

  @override
  State<TecnicoFormScreen> createState() => _TecnicoFormScreenState();
}

class _TecnicoFormScreenState extends State<TecnicoFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController nome;
  late final TextEditingController contato;
  late final TextEditingController especialidade;
  late SituacaoTecnico situacao;

  @override
  void initState() {
    super.initState();
    nome = TextEditingController(text: widget.tecnico?.nome);
    contato = TextEditingController(text: widget.tecnico?.contato);
    especialidade = TextEditingController(text: widget.tecnico?.especialidade);
    situacao = widget.tecnico?.situacao ?? SituacaoTecnico.ativo;
  }

  @override
  void dispose() {
    nome.dispose();
    contato.dispose();
    especialidade.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    try {
      await context.read<AppController>().facade.tecnicos.salvar(
            Tecnico(
              id: widget.tecnico?.id,
              nome: nome.text.trim(),
              contato: contato.text.trim(),
              especialidade: especialidade.text.trim(),
              situacao: situacao,
            ),
          );
      if (!mounted) return;
      snackOk(context, 'Técnico salvo.');
      Navigator.pop(context);
    } catch (_) {
      snackErro(context, 'Não foi possível salvar o técnico.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tecnico == null ? 'Novo técnico' : 'Editar técnico')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => AppValidators.obrigatorio(v, 'Nome'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: contato,
              decoration: const InputDecoration(labelText: 'Contato'),
              validator: AppValidators.telefone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: especialidade,
              decoration: const InputDecoration(labelText: 'Especialidade'),
              validator: (v) => AppValidators.obrigatorio(v, 'Especialidade'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SituacaoTecnico>(
              initialValue: situacao,
              decoration: const InputDecoration(labelText: 'Situação'),
              items: SituacaoTecnico.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => situacao = v!),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
