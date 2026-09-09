import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'evidence_bytes.dart';

/// Exibe evidência persistida (data URI ou arquivo local).
/// TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class EvidenceImage extends StatelessWidget {
  const EvidenceImage({super.key, this.stored});
  final String? stored;

  @override
  Widget build(BuildContext context) {
    final bytes = decodeEvidence(stored);
    if (bytes == null) {
      return const Center(child: Icon(Icons.image_not_supported_outlined));
    }
    return Image.memory(bytes, fit: BoxFit.cover);
  }
}

Uint8List? decodeEvidence(String? stored) {
  if (stored == null || stored.isEmpty) return null;
  try {
    if (stored.startsWith('data:')) {
      return base64Decode(stored.split(',').last);
    }
    return bytesFromFilePath(stored);
  } catch (_) {
    return null;
  }
}
