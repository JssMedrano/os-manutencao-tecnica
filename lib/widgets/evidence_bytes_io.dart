import 'dart:io';
import 'dart:typed_data';

Uint8List? bytesFromFilePath(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) return file.readAsBytesSync();
  } catch (_) {}
  return null;
}
