import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/enums.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../widgets/kpi_card.dart';

/// Painel de indicadores. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onAbrirFiltro});
  final void Function(OsStatus? status, {bool urgentes, bool atrasadas})
      onAbrirFiltro;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final i = app.indicadores;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Painel operacional',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text(
          'Acompanhe chamados abertos, urgentes, atrasados e o valor das OS.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Total de OS',
                valor: '${i.total}',
                icone: Icons.assignment,
                cor: AppTheme.navy,
                onTap: () => onAbrirFiltro(null),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Abertas',
                valor: '${i.abertas}',
                icone: Icons.fiber_new,
                cor: Colors.blueGrey,
                onTap: () => onAbrirFiltro(OsStatus.aberta),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Em atendimento',
                valor: '${i.emAtendimento}',
                icone: Icons.handyman,
                cor: AppTheme.teal,
                onTap: () => onAbrirFiltro(OsStatus.emAtendimento),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Aguardando peça',
                valor: '${i.aguardandoPeca}',
                icone: Icons.inventory_2_outlined,
                cor: AppTheme.amber,
                onTap: () => onAbrirFiltro(OsStatus.aguardandoPeca),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Concluídas',
                valor: '${i.concluidas}',
                icone: Icons.check_circle_outline,
                cor: Colors.green,
                onTap: () => onAbrirFiltro(OsStatus.concluida),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Urgentes',
                valor: '${i.urgentes}',
                icone: Icons.priority_high,
                cor: AppTheme.danger,
                onTap: () => onAbrirFiltro(null, urgentes: true),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Atrasadas',
                valor: '${i.atrasadas}',
                icone: Icons.timer_off_outlined,
                cor: Colors.deepOrange,
                onTap: () => onAbrirFiltro(null, atrasadas: true),
              ),
            ),
            SizedBox(
              width: 280,
              child: KpiCard(
                titulo: 'Valor total registrado',
                valor: AppFormatters.dinheiro(i.valorTotal),
                icone: Icons.payments_outlined,
                cor: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const labels = ['Abt', 'Atend', 'Peça', 'OK', 'Urg', 'Atr'];
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length) return const SizedBox();
                          return Text(labels[i], style: const TextStyle(fontSize: 11));
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _bar(0, i.abertas.toDouble(), Colors.blueGrey),
                    _bar(1, i.emAtendimento.toDouble(), AppTheme.teal),
                    _bar(2, i.aguardandoPeca.toDouble(), AppTheme.amber),
                    _bar(3, i.concluidas.toDouble(), Colors.green),
                    _bar(4, i.urgentes.toDouble(), AppTheme.danger),
                    _bar(5, i.atrasadas.toDouble(), Colors.deepOrange),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y, Color cor) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: cor, width: 22, borderRadius: BorderRadius.circular(6))],
    );
  }
}
