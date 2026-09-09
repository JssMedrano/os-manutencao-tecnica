import 'package:flutter/material.dart';

/// Cartão de indicador do painel. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.onTap,
  });

  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cor.withValues(alpha: 0.15),
                child: Icon(icone, color: cor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: Theme.of(context).textTheme.labelMedium),
                    Text(
                      valor,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
