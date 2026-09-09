import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// SQLite no navegador via WASM + IndexedDB. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
Future<void> initSqliteFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}

Future<String> resolveSqlitePath(String dbName) async => dbName;
