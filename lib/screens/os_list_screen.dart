import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/enums.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/ordem_servico.dart';
import '../widgets/empty_hint.dart';
import '../widgets/status_chip.dart';
import 'os_detail_screen.dart';
import 'os_form_screen.dart';

/// Lista, busca e filtros de OS. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OsListScreen extends StatefulWidget {
  const OsListScreen({super.key, this.somenteAtrasadas = false, this.somenteUrgentes = false});
  final bool somenteAtrasadas;
  final bool somenteUrgentes;

  @override
  State<OsListScreen> createState() => _OsListScreenState();
}

class _OsListScreenState extends State<OsListScreen> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    var lista = app.ordens;
    if (widget.somenteAtrasadas) {
      lista = lista.where((o) => o.atrasada).toList();
    }
    if (widget.somenteUrgentes) {
      lista = lista.where((o) => o.urgente).toList();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const OsFormScreen()));
          if (context.mounted) await context.read<AppController>().carregarTudo();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _busca,
              decoration: const InputDecoration(
                labelText: 'Buscar por número, cliente, equipamento ou técnico',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => app.definirFiltros(busca: v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DropdownButton<OsStatus?>(
                  value: app.filtroStatus,
                  hint: const Text('Status'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos os status')),
                    ...OsStatus.values.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    ),
                  ],
                  onChanged: (v) => app.definirFiltros(
                    status: v,
                    limparStatus: v == null,
                  ),
                ),
                DropdownButton<OsPrioridade?>(
                  value: app.filtroPrioridade,
                  hint: const Text('Prioridade'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...OsPrioridade.values.map(
                      (p) => DropdownMenuItem(value: p, child: Text(p.label)),
                    ),
                  ],
                  onChanged: (v) => app.definirFiltros(
                    prioridade: v,
                    limparPrioridade: v == null,
                  ),
                ),
                DropdownButton<int?>(
                  value: app.filtroTecnico,
                  hint: const Text('Técnico'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...app.tecnicos.map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.nome)),
                    ),
                  ],
                  onChanged: (v) => app.definirFiltros(
                    tecnicoId: v,
                    limparTecnico: v == null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const EmptyHint(texto: 'Nenhuma ordem encontrada com os filtros atuais.')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    itemBuilder: (_, i) => _OsTile(os: lista[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OsTile extends StatelessWidget {
  const _OsTile({required this.os});
  final OrdemServico os;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: os.atrasada
          ? Colors.deepOrange.withValues(alpha: 0.08)
          : os.urgente
              ? AppTheme.danger.withValues(alpha: 0.06)
              : null,
      child: ListTile(
        title: Text('${os.codigo} · ${os.clienteNome ?? ''}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(os.equipamentoRotulo ?? ''),
            Text('Técnico: ${os.tecnicoNome ?? 'não atribuído'} · Prazo ${AppFormatters.dataBr(os.dataLimite)}'),
            Text('Total ${AppFormatters.dinheiro(os.valorTotal)}'),
            Wrap(
              spacing: 6,
              children: [
                StatusChip(status: os.status),
                PrioridadeChip(prioridade: os.prioridade),
                if (os.atrasada)
                  const Chip(
                    label: Text('ATRASADA'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Color(0x33E65100),
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OsDetailScreen(ordemId: os.id!)),
          );
          if (context.mounted) await context.read<AppController>().carregarTudo();
        },
      ),
    );
  }
}
