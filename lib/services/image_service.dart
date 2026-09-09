import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Evidências como data URI, válidas no desktop e na web.
/// TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ImageService {
  final _picker = ImagePicker();

  Future<String?> selecionarArquivo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && !kIsWeb) {
        bytes = await XFile(file.path!).readAsBytes();
      }
      if (bytes == null) return null;
      return _paraDataUri(bytes, file.extension);
    } catch (e) {
      debugPrint('Falha ao selecionar arquivo: $e');
      return null;
    }
  }

  Future<String?> capturarCamera() async {
    try {
      final shot = await _picker.pickImage(source: ImageSource.camera);
      if (shot == null) return null;
      final bytes = await shot.readAsBytes();
      return _paraDataUri(bytes, shot.name.split('.').last);
    } catch (e) {
      debugPrint('Câmera indisponível, tentando galeria: $e');
      return selecionarArquivo();
    }
  }

  String _paraDataUri(Uint8List bytes, String? ext) {
    final tipo = switch ((ext ?? 'png').toLowerCase()) {
      'jpg' || 'jpeg' => 'jpeg',
      'gif' => 'gif',
      'webp' => 'webp',
      _ => 'png',
    };
    return 'data:image/$tipo;base64,${base64Encode(bytes)}';
  }
}
