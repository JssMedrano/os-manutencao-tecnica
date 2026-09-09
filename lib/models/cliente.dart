/// Cliente da oficina. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class Cliente {
  final int? id;
  final String nome;
  final String documento;
  final String telefone;
  final String email;
  final String endereco;

  const Cliente({
    this.id,
    required this.nome,
    required this.documento,
    required this.telefone,
    required this.email,
    required this.endereco,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'documento': documento,
        'telefone': telefone,
        'email': email,
        'endereco': endereco,
      };

  factory Cliente.fromMap(Map<String, dynamic> map) => Cliente(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        documento: map['documento'] as String,
        telefone: map['telefone'] as String,
        email: map['email'] as String,
        endereco: map['endereco'] as String,
      );
}
