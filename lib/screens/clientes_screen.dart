import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/validators.dart';
import '../models/cliente.dart';
import '../widgets/empty_hint.dart';
import '../widgets/feedback.dart';

/// CRUD de clientes. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo cliente'),
      ),
      body: app.clientes.isEmpty
          ? const EmptyHint(texto: 'Nenhum cliente cadastrado.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: app.clientes.length,
              itemBuilder: (_, i) {
                final c = app.clientes[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.apartment)),
                    title: Text(c.nome),
                    subtitle: Text('${c.documento} · ${c.telefone}\n${c.email}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _form(context, cliente: c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await confirmarExclusao(
                              context,
                              titulo: 'Excluir cliente',
                              mensagem: 'Deseja excluir ${c.nome}?',
                            );
                            if (!ok || !context.mounted) return;
                            final erro = await app.facade.clientes.excluir(c.id!);
                            if (!context.mounted) return;
                            if (erro != null) {
                              snackErro(context, erro);
                            } else {
                              snackOk(context, 'Cliente excluído.');
                              await app.carregarTudo();
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () => _form(context, cliente: c),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _form(BuildContext context, {Cliente? cliente}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormScreen(cliente: cliente)),
    );
    if (context.mounted) {
      await context.read<AppController>().carregarTudo();
    }
  }
}

class ClienteFormScreen extends StatefulWidget {
  const ClienteFormScreen({super.key, this.cliente});
  final Cliente? cliente;

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController nome;
  late final TextEditingController documento;
  late final TextEditingController telefone;
  late final TextEditingController email;
  late final TextEditingController endereco;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    nome = TextEditingController(text: c?.nome);
    documento = TextEditingController(text: c?.documento);
    telefone = TextEditingController(text: c?.telefone);
    email = TextEditingController(text: c?.email);
    endereco = TextEditingController(text: c?.endereco);
  }

  @override
  void dispose() {
    nome.dispose();
    documento.dispose();
    telefone.dispose();
    email.dispose();
    endereco.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final cliente = Cliente(
      id: widget.cliente?.id,
      nome: nome.text.trim(),
      documento: documento.text.trim(),
      telefone: telefone.text.trim(),
      email: email.text.trim(),
      endereco: endereco.text.trim(),
    );
    try {
      await context.read<AppController>().facade.clientes.salvar(cliente);
      if (!mounted) return;
      snackOk(context, 'Cliente salvo com sucesso.');
      Navigator.pop(context);
    } catch (_) {
      snackErro(context, 'Não foi possível salvar o cliente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cliente == null ? 'Novo cliente' : 'Editar cliente')),
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
              controller: documento,
              decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
              validator: AppValidators.documento,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: telefone,
              decoration: const InputDecoration(labelText: 'Telefone'),
              validator: AppValidators.telefone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: email,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: AppValidators.email,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: endereco,
              decoration: const InputDecoration(labelText: 'Endereço'),
              validator: (v) => AppValidators.obrigatorio(v, 'Endereço'),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
