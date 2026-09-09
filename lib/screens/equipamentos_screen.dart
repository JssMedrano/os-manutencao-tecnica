import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/validators.dart';
import '../models/cliente.dart';
import '../models/equipamento.dart';
import '../widgets/empty_hint.dart';
import '../widgets/feedback.dart';

/// CRUD de equipamentos. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class EquipamentosScreen extends StatelessWidget {
  const EquipamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo equipamento'),
      ),
      body: app.equipamentos.isEmpty
          ? const EmptyHint(texto: 'Nenhum equipamento cadastrado.')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: app.equipamentos.length,
              itemBuilder: (_, i) {
                final e = app.equipamentos[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.devices_other)),
                    title: Text(e.rotulo),
                    subtitle: Text(
                      '${e.clienteNome ?? ''} · Série ${e.numeroSerie}\nPatrimônio ${e.patrimonio}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _form(context, eq: e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await confirmarExclusao(
                              context,
                              titulo: 'Excluir equipamento',
                              mensagem: 'Deseja excluir ${e.rotulo}?',
                            );
                            if (!ok || !context.mounted) return;
                            final erro = await app.facade.equipamentos.excluir(e.id!);
                            if (!context.mounted) return;
                            if (erro != null) {
                              snackErro(context, erro);
                            } else {
                              snackOk(context, 'Equipamento excluído.');
                              await app.carregarTudo();
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () => _form(context, eq: e),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _form(BuildContext context, {Equipamento? eq}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EquipamentoFormScreen(equipamento: eq)),
    );
    if (context.mounted) await context.read<AppController>().carregarTudo();
  }
}

class EquipamentoFormScreen extends StatefulWidget {
  const EquipamentoFormScreen({super.key, this.equipamento});
  final Equipamento? equipamento;

  @override
  State<EquipamentoFormScreen> createState() => _EquipamentoFormScreenState();
}

class _EquipamentoFormScreenState extends State<EquipamentoFormScreen> {
  final _form = GlobalKey<FormState>();
  int? clienteId;
  late final TextEditingController tipo;
  late final TextEditingController marca;
  late final TextEditingController modelo;
  late final TextEditingController serie;
  late final TextEditingController patrimonio;
  late final TextEditingController obs;

  @override
  void initState() {
    super.initState();
    clienteId = widget.equipamento?.clienteId;
    tipo = TextEditingController(text: widget.equipamento?.tipo);
    marca = TextEditingController(text: widget.equipamento?.marca);
    modelo = TextEditingController(text: widget.equipamento?.modelo);
    serie = TextEditingController(text: widget.equipamento?.numeroSerie);
    patrimonio = TextEditingController(text: widget.equipamento?.patrimonio);
    obs = TextEditingController(text: widget.equipamento?.observacoes);
  }

  @override
  void dispose() {
    tipo.dispose();
    marca.dispose();
    modelo.dispose();
    serie.dispose();
    patrimonio.dispose();
    obs.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (clienteId == null) {
      snackErro(context, 'Selecione o cliente dono do equipamento.');
      return;
    }
    try {
      await context.read<AppController>().facade.equipamentos.salvar(
            Equipamento(
              id: widget.equipamento?.id,
              clienteId: clienteId!,
              tipo: tipo.text.trim(),
              marca: marca.text.trim(),
              modelo: modelo.text.trim(),
              numeroSerie: serie.text.trim(),
              patrimonio: patrimonio.text.trim(),
              observacoes: obs.text.trim(),
            ),
          );
      if (!mounted) return;
      snackOk(context, 'Equipamento salvo.');
      Navigator.pop(context);
    } catch (_) {
      snackErro(context, 'Não foi possível salvar o equipamento.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<AppController>().clientes;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipamento == null ? 'Novo equipamento' : 'Editar equipamento'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: clienteId,
              decoration: const InputDecoration(labelText: 'Cliente'),
              items: clientes
                  .map((Cliente c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() => clienteId = v),
              validator: (v) => v == null ? 'Cliente é obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              validator: (v) => AppValidators.obrigatorio(v, 'Tipo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: marca,
              decoration: const InputDecoration(labelText: 'Marca'),
              validator: (v) => AppValidators.obrigatorio(v, 'Marca'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: modelo,
              decoration: const InputDecoration(labelText: 'Modelo'),
              validator: (v) => AppValidators.obrigatorio(v, 'Modelo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: serie,
              decoration: const InputDecoration(labelText: 'Número de série'),
              validator: (v) => AppValidators.obrigatorio(v, 'Número de série'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: patrimonio,
              decoration: const InputDecoration(labelText: 'Patrimônio'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: obs,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
