import '../models/equipamento.dart';
import '../services/database_service.dart';

/// Persistência de equipamentos. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class EquipamentoRepository {
  Future<List<Equipamento>> listar({int? clienteId}) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT e.*, c.nome AS cliente_nome
      FROM equipamentos e
      INNER JOIN clientes c ON c.id = e.cliente_id
      ${clienteId == null ? '' : 'WHERE e.cliente_id = ?'}
      ORDER BY c.nome, e.tipo
    ''', clienteId == null ? [] : [clienteId]);
    return rows.map(Equipamento.fromMap).toList();
  }

  Future<int> salvar(Equipamento eq) async {
    final db = await DatabaseService.instance.database;
    if (eq.id == null) {
      return db.insert('equipamentos', eq.toMap()..remove('id'));
    }
    await db.update(
      'equipamentos',
      eq.toMap(),
      where: 'id = ?',
      whereArgs: [eq.id],
    );
    return eq.id!;
  }

  Future<String?> excluir(int id) async {
    final db = await DatabaseService.instance.database;
    final os = await db.query(
      'ordens',
      where: 'equipamento_id = ?',
      whereArgs: [id],
    );
    if (os.isNotEmpty) {
      return 'Não é possível excluir: existem ordens vinculadas a este equipamento.';
    }
    await db.delete('equipamentos', where: 'id = ?', whereArgs: [id]);
    return null;
  }
}
