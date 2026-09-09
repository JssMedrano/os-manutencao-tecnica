import '../models/tecnico.dart';
import '../services/database_service.dart';

/// Persistência de técnicos. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class TecnicoRepository {
  Future<List<Tecnico>> listar({bool apenasAtivos = false}) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'tecnicos',
      where: apenasAtivos ? 'situacao = ?' : null,
      whereArgs: apenasAtivos ? ['ativo'] : null,
      orderBy: 'nome',
    );
    return rows.map(Tecnico.fromMap).toList();
  }

  Future<int> salvar(Tecnico tecnico) async {
    final db = await DatabaseService.instance.database;
    if (tecnico.id == null) {
      return db.insert('tecnicos', tecnico.toMap()..remove('id'));
    }
    await db.update(
      'tecnicos',
      tecnico.toMap(),
      where: 'id = ?',
      whereArgs: [tecnico.id],
    );
    return tecnico.id!;
  }

  Future<String?> excluir(int id) async {
    final db = await DatabaseService.instance.database;
    final os = await db.query(
      'ordens',
      where: 'tecnico_id = ? AND status NOT IN (?, ?)',
      whereArgs: [id, 'concluida', 'cancelada'],
    );
    if (os.isNotEmpty) {
      return 'Não é possível excluir: o técnico possui OS em andamento.';
    }
    await db.delete('tecnicos', where: 'id = ?', whereArgs: [id]);
    return null;
  }
}
