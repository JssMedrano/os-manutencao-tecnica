import 'package:flutter/material.dart';

/// Estado vazio de listas. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.texto, this.icone = Icons.inbox_outlined});
  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 56, color: Colors.blueGrey),
          const SizedBox(height: 8),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
