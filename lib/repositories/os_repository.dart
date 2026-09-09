import '../core/enums.dart';
import '../core/os_status_machine.dart';
import '../models/historico_os.dart';
import '../models/item_os.dart';
import '../models/ordem_servico.dart';
import '../services/database_service.dart';

/// Persistência de OS, itens e histórico. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OrdemRepository {
  Future<String> proximoCodigo() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery(
      'SELECT codigo FROM ordens ORDER BY id DESC LIMIT 1',
    );
    if (rows.isEmpty) return 'OS-2026-0001';
    final atual = rows.first['codigo'] as String;
    final n = int.tryParse(atual.split('-').last) ?? 0;
    return 'OS-2026-${(n + 1).toString().padLeft(4, '0')}';
  }

  Future<List<OrdemServico>> listar({
    String busca = '',
    OsStatus? status,
    OsPrioridade? prioridade,
    int? tecnicoId,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>[];
    final args = <Object?>[];

    if (busca.trim().isNotEmpty) {
      where.add('''
        (o.codigo LIKE ? OR c.nome LIKE ? OR t.nome LIKE ?
         OR (e.tipo || ' ' || e.marca || ' ' || e.modelo) LIKE ?)
      ''');
      final q = '%${busca.trim()}%';
      args.addAll([q, q, q, q]);
    }
    if (status != null) {
      where.add('o.status = ?');
      args.add(status.name);
    }
    if (prioridade != null) {
      where.add('o.prioridade = ?');
      args.add(prioridade.name);
    }
    if (tecnicoId != null) {
      where.add('o.tecnico_id = ?');
      args.add(tecnicoId);
    }

    final sql = '''
      SELECT o.*,
             c.nome AS cliente_nome,
             t.nome AS tecnico_nome,
             (e.tipo || ' ' || e.marca || ' ' || e.modelo) AS equipamento_rotulo
      FROM ordens o
      INNER JOIN clientes c ON c.id = o.cliente_id
      INNER JOIN equipamentos e ON e.id = o.equipamento_id
      LEFT JOIN tecnicos t ON t.id = o.tecnico_id
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      ORDER BY o.data_abertura DESC
    ''';
    final rows = await db.rawQuery(sql, args);
    final result = <OrdemServico>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final itens = await listarItens(id);
      result.add(OrdemServico.fromMap(row, itens: itens));
    }
    return result;
  }

  Future<OrdemServico?> buscar(int id) async {
    final lista = await listar();
    try {
      return lista.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ItemOs>> listarItens(int ordemId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'itens_os',
      where: 'ordem_id = ?',
      whereArgs: [idFor(ordemId)],
    );
    return rows.map(ItemOs.fromMap).toList();
  }

  int idFor(int id) => id;

  Future<List<HistoricoOs>> historico(int ordemId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'historico_os',
      where: 'ordem_id = ?',
      whereArgs: [ordemId],
      orderBy: 'data_hora DESC',
    );
    return rows.map(HistoricoOs.fromMap).toList();
  }

  Future<int> salvar(OrdemServico os, {required String usuario}) async {
    final db = await DatabaseService.instance.database;
    final map = os.toMap()..remove('id');
    int id;
    if (os.id == null) {
      id = await db.insert('ordens', map);
      await _hist(db, id, 'OS ${os.codigo} aberta.', usuario);
    } else {
      id = os.id!;
      await db.update('ordens', map, where: 'id = ?', whereArgs: [id]);
      await _hist(db, id, 'OS ${os.codigo} atualizada.', usuario);
    }
    await db.delete('itens_os', where: 'ordem_id = ?', whereArgs: [id]);
    for (final item in os.itens) {
      await db.insert('itens_os', {
        ...item.toMap()..remove('id'),
        'ordem_id': id,
      });
    }
    return id;
  }

  Future<String?> alterarStatus({
    required OrdemServico os,
    required OsStatus novo,
    required String usuario,
  }) async {
    if (!OsStatusMachine.podeTransitar(os.status, novo)) {
      return 'Transição inválida: ${os.status.label} → ${novo.label}.';
    }
    if (novo == OsStatus.atribuida) {
      final msg = OsStatusMachine.validarAtribuicao(os.tecnicoId);
      if (msg != null) return msg;
    }
    if (novo == OsStatus.concluida) {
      final msg = OsStatusMachine.validarConclusao(
        diagnostico: os.diagnostico,
        solucao: os.solucao,
      );
      if (msg != null) return msg;
    }
    final atualizada = os.copyWith(
      status: novo,
      dataConclusao: novo == OsStatus.concluida ? DateTime.now() : os.dataConclusao,
    );
    await salvar(atualizada, usuario: usuario);
    final db = await DatabaseService.instance.database;
    await _hist(
      db,
      os.id!,
      'Status alterado: ${os.status.label} → ${novo.label}.',
      usuario,
    );
    return null;
  }

  Future<String?> excluir(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('ordens', where: 'id = ?', whereArgs: [id]);
    return null;
  }

  Future<void> _hist(
    dynamic db,
    int ordemId,
    String desc,
    String usuario,
  ) async {
    await db.insert('historico_os', {
      'ordem_id': ordemId,
      'descricao': desc,
      'usuario': usuario,
      'data_hora': DateTime.now().toIso8601String(),
    });
  }
}
