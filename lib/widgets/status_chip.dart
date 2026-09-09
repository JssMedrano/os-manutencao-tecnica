import 'package:flutter/material.dart';

import '../core/enums.dart';
import '../core/theme.dart';

/// Chips de status e prioridade. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final OsStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = {
      OsStatus.aberta: Colors.blueGrey,
      OsStatus.atribuida: Colors.indigo,
      OsStatus.emAtendimento: AppTheme.teal,
      OsStatus.aguardandoPeca: AppTheme.amber,
      OsStatus.concluida: Colors.green,
      OsStatus.cancelada: Colors.grey,
    };
    return Chip(
      label: Text(status.label),
      visualDensity: VisualDensity.compact,
      backgroundColor: colors[status]!.withValues(alpha: 0.18),
      labelStyle: TextStyle(color: colors[status], fontWeight: FontWeight.w600),
    );
  }
}

class PrioridadeChip extends StatelessWidget {
  const PrioridadeChip({super.key, required this.prioridade});
  final OsPrioridade prioridade;

  @override
  Widget build(BuildContext context) {
    final color = {
      OsPrioridade.baixa: Colors.blueGrey,
      OsPrioridade.media: Colors.blue,
      OsPrioridade.alta: Colors.deepOrange,
      OsPrioridade.urgente: AppTheme.danger,
    }[prioridade]!;
    return Chip(
      avatar: Icon(
        prioridade == OsPrioridade.urgente
            ? Icons.priority_high
            : Icons.flag_outlined,
        size: 16,
        color: color,
      ),
      label: Text(prioridade.label),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.16),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
