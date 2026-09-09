/// Histórico de evolução da OS. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class HistoricoOs {
  final int? id;
  final int ordemId;
  final String descricao;
  final String usuario;
  final DateTime dataHora;

  const HistoricoOs({
    this.id,
    required this.ordemId,
    required this.descricao,
    required this.usuario,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ordem_id': ordemId,
        'descricao': descricao,
        'usuario': usuario,
        'data_hora': dataHora.toIso8601String(),
      };

  factory HistoricoOs.fromMap(Map<String, dynamic> map) => HistoricoOs(
        id: map['id'] as int?,
        ordemId: map['ordem_id'] as int,
        descricao: map['descricao'] as String,
        usuario: map['usuario'] as String,
        dataHora: DateTime.parse(map['data_hora'] as String),
      );
}
