/// Peça ou material da OS. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ItemOs {
  final int? id;
  final int ordemId;
  final String descricao;
  final double quantidade;
  final double valorUnitario;

  const ItemOs({
    this.id,
    required this.ordemId,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  double get subtotal => quantidade * valorUnitario;

  Map<String, dynamic> toMap() => {
        'id': id,
        'ordem_id': ordemId,
        'descricao': descricao,
        'quantidade': quantidade,
        'valor_unitario': valorUnitario,
      };

  factory ItemOs.fromMap(Map<String, dynamic> map) => ItemOs(
        id: map['id'] as int?,
        ordemId: map['ordem_id'] as int,
        descricao: map['descricao'] as String,
        quantidade: (map['quantidade'] as num).toDouble(),
        valorUnitario: (map['valor_unitario'] as num).toDouble(),
      );
}
