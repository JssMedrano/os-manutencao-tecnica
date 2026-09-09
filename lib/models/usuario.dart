/// Usuário local com perfil. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class Usuario {
  final int? id;
  final String nome;
  final String login;
  final String senhaHash;
  final String perfil;
  final int? tecnicoId;

  const Usuario({
    this.id,
    required this.nome,
    required this.login,
    required this.senhaHash,
    required this.perfil,
    this.tecnicoId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'login': login,
        'senha_hash': senhaHash,
        'perfil': perfil,
        'tecnico_id': tecnicoId,
      };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        login: map['login'] as String,
        senhaHash: map['senha_hash'] as String,
        perfil: map['perfil'] as String,
        tecnicoId: map['tecnico_id'] as int?,
      );

  bool get isAdmin => perfil == 'administrador';
  bool get isAtendente => perfil == 'atendente';
  bool get isTecnico => perfil == 'tecnico';
}
