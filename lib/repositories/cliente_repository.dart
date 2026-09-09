import '../models/cliente.dart';
import '../services/database_service.dart';

/// Persistência de clientes. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ClienteRepository {
  Future<List<Cliente>> listar() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('clientes', orderBy: 'nome');
    return rows.map(Cliente.fromMap).toList();
  }

  Future<Cliente?> buscar(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('clientes', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Cliente.fromMap(rows.first);
  }

  Future<int> salvar(Cliente cliente) async {
    final db = await DatabaseService.instance.database;
    if (cliente.id == null) {
      return db.insert('clientes', cliente.toMap()..remove('id'));
    }
    await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
    return cliente.id!;
  }

  Future<String?> excluir(int id) async {
    final db = await DatabaseService.instance.database;
    final eqs = await db.query(
      'equipamentos',
      where: 'cliente_id = ?',
      whereArgs: [id],
    );
    if (eqs.isNotEmpty) {
      return 'Não é possível excluir: existem equipamentos vinculados a este cliente.';
    }
    final os = await db.query(
      'ordens',
      where: 'cliente_id = ?',
      whereArgs: [id],
    );
    if (os.isNotEmpty) {
      return 'Não é possível excluir: existem ordens de serviço vinculadas.';
    }
    await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
    return null;
  }
}
