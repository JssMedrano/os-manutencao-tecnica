import '../models/usuario.dart';
import '../services/database_service.dart';

/// Acesso a usuários. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class UsuarioRepository {
  Future<Usuario?> autenticar(String login, String senha) async {
    final db = await DatabaseService.instance.database;
    final hash = DatabaseService.hashSenha(senha.trim());
    final rows = await db.query(
      'usuarios',
      where: 'login = ? AND senha_hash = ?',
      whereArgs: [login.trim().toLowerCase(), hash],
    );
    if (rows.isEmpty) return null;
    return Usuario.fromMap(rows.first);
  }
}
