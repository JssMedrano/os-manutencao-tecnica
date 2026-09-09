import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Inicialização SQLite nativa. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
Future<void> initSqliteFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

Future<String> resolveSqlitePath(String dbName) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'os_manutencao'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  return p.join(folder.path, dbName);
}
