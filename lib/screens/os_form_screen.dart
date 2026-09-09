import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/atendimento_factory.dart';
import '../core/enums.dart';
import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/equipamento.dart';
import '../models/item_os.dart';
import '../models/ordem_servico.dart';
import '../widgets/feedback.dart';

/// Abertura e edição de OS. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OsFormScreen extends StatefulWidget {
  const OsFormScreen({super.key, this.ordem});
  final OrdemServico? ordem;

  @override
  State<OsFormScreen> createState() => _OsFormScreenState();
}

class _OsFormScreenState extends State<OsFormScreen> {
  final _form = GlobalKey<FormState>();
  int? clienteId;
  int? equipamentoId;
  int? tecnicoId;
  String tipo = 'corretiva';
  OsPrioridade prioridade = OsPrioridade.media;
  DateTime? dataLimite;
  late final TextEditingController problema;
  late final TextEditingController diagnostico;
  late final TextEditingController solucao;
  late final TextEditingController maoObra;
  final List<ItemOs> itens = [];

  @override
  void initState() {
    super.initState();
    final o = widget.ordem;
    clienteId = o?.clienteId;
    equipamentoId = o?.equipamentoId;
    tecnicoId = o?.tecnicoId;
    tipo = o?.tipoAtendimento ?? 'corretiva';
    prioridade = o?.prioridade ?? OsPrioridade.media;
    dataLimite = o?.dataLimite ?? DateTime.now().add(AtendimentoFactory.criar(tipo).prazoPadrao);
    problema = TextEditingController(text: o?.descricaoProblema);
    diagnostico = TextEditingController(text: o?.diagnostico);
    solucao = TextEditingController(text: o?.solucao);
    maoObra = TextEditingController(text: o == null ? '0' : o.valorMaoObra.toStringAsFixed(2));
    if (o != null) itens.addAll(o.itens);
  }

  @override
  void dispose() {
    problema.dispose();
    diagnostico.dispose();
    solucao.dispose();
    maoObra.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (clienteId == null || equipamentoId == null) {
      snackErro(context, 'Selecione cliente e equipamento.');
      return;
    }
    final mao = AppValidators.parseValor(maoObra.text);
    if (mao == null) {
      snackErro(context, 'Valor de mão de obra inválido.');
      return;
    }
    final app = context.read<AppController>();
    final usuario = context.read<AuthController>().usuario?.nome ?? 'Usuário';
    final codigo = widget.ordem?.codigo ?? await app.facade.ordens.proximoCodigo();
    final os = OrdemServico(
      id: widget.ordem?.id,
      codigo: codigo,
      clienteId: clienteId!,
      equipamentoId: equipamentoId!,
      tecnicoId: tecnicoId,
      tipoAtendimento: tipo,
      descricaoProblema: problema.text.trim(),
      diagnostico: diagnostico.text.trim(),
      solucao: solucao.text.trim(),
      prioridade: prioridade,
      status: widget.ordem?.status ?? OsStatus.aberta,
      dataAbertura: widget.ordem?.dataAbertura ?? DateTime.now(),
      dataLimite: dataLimite,
      dataConclusao: widget.ordem?.dataConclusao,
      valorMaoObra: mao,
      imagemAntes: widget.ordem?.imagemAntes,
      imagemDepois: widget.ordem?.imagemDepois,
      itens: itens.map((i) => ItemOs(
            descricao: i.descricao,
            quantidade: i.quantidade,
            valorUnitario: i.valorUnitario,
            ordemId: widget.ordem?.id ?? 0,
          )).toList(),
    );
    try {
      await app.facade.ordens.salvar(os, usuario: usuario);
      if (!mounted) return;
      snackOk(context, 'Ordem de serviço salva.');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      snackErro(context, 'Não foi possível salvar a ordem de serviço.');
    }
  }

  Future<void> _addItem() async {
    final desc = TextEditingController();
    final qtd = TextEditingController(text: '1');
    final vu = TextEditingController(text: '0');
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peça / material'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => AppValidators.obrigatorio(v, 'Descrição'),
              ),
              TextFormField(
                controller: qtd,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
              TextFormField(
                controller: vu,
                decoration: const InputDecoration(labelText: 'Valor unitário'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    final q = AppValidators.parseValor(qtd.text);
    final u = AppValidators.parseValor(vu.text);
    if (q == null || u == null) {
      if (!mounted) return;
      snackErro(context, 'Quantidade ou valor inválidos.');
      return;
    }
    setState(() {
      itens.add(ItemOs(ordemId: 0, descricao: desc.text.trim(), quantidade: q, valorUnitario: u));
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final eqs = app.equipamentos.where((e) => clienteId == null || e.clienteId == clienteId).toList();
    final totalPecas = itens.fold<double>(0, (a, i) => a + i.subtotal);
    final mao = AppValidators.parseValor(maoObra.text) ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(widget.ordem == null ? 'Nova ordem de serviço' : 'Editar ${widget.ordem!.codigo}')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: clienteId,
              decoration: const InputDecoration(labelText: 'Cliente'),
              items: app.clientes
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
                  .toList(),
              onChanged: (v) => setState(() {
                clienteId = v;
                equipamentoId = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: equipamentoId,
              decoration: const InputDecoration(labelText: 'Equipamento'),
              items: eqs
                  .map((Equipamento e) => DropdownMenuItem(value: e.id, child: Text(e.rotulo)))
                  .toList(),
              onChanged: (v) => setState(() => equipamentoId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: tecnicoId,
              decoration: const InputDecoration(labelText: 'Técnico responsável'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Não atribuído')),
                ...app.tecnicos.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))),
              ],
              onChanged: (v) => setState(() => tecnicoId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: tipo,
              decoration: const InputDecoration(labelText: 'Tipo de atendimento'),
              items: AtendimentoFactory.todos()
                  .map((t) => DropdownMenuItem(value: t.codigo, child: Text(t.descricao)))
                  .toList(),
              onChanged: (v) => setState(() {
                tipo = v!;
                dataLimite = DateTime.now().add(AtendimentoFactory.criar(tipo).prazoPadrao);
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<OsPrioridade>(
              initialValue: prioridade,
              decoration: const InputDecoration(labelText: 'Prioridade'),
              items: OsPrioridade.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (v) => setState(() => prioridade = v!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Prazo previsto: ${AppFormatters.dataBr(dataLimite)}'),
              trailing: const Icon(Icons.date_range),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                  initialDate: dataLimite ?? DateTime.now(),
                );
                if (d != null) setState(() => dataLimite = d);
              },
            ),
            TextFormField(
              controller: problema,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição do problema'),
              validator: (v) => AppValidators.obrigatorio(v, 'Descrição do problema'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: diagnostico,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Diagnóstico técnico'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: solucao,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Solução aplicada'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: maoObra,
              decoration: const InputDecoration(labelText: 'Valor da mão de obra'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Peças e materiais', style: TextStyle(fontWeight: FontWeight.bold))),
                TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Item')),
              ],
            ),
            ...itens.asMap().entries.map((e) {
              final i = e.value;
              return ListTile(
                title: Text(i.descricao),
                subtitle: Text('${i.quantidade} x ${AppFormatters.dinheiro(i.valorUnitario)} = ${AppFormatters.dinheiro(i.subtotal)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => itens.removeAt(e.key)),
                ),
              );
            }),
            const Divider(),
            Text('Peças: ${AppFormatters.dinheiro(totalPecas)}'),
            Text('Mão de obra: ${AppFormatters.dinheiro(mao)}'),
            Text(
              'TOTAL: ${AppFormatters.dinheiro(totalPecas + mao)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _salvar, child: const Text('Salvar ordem')),
          ],
        ),
      ),
    );
  }
}
