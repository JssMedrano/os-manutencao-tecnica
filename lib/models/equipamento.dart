/// Ativo vinculado a um cliente. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class Equipamento {
  final int? id;
  final int clienteId;
  final String tipo;
  final String marca;
  final String modelo;
  final String numeroSerie;
  final String patrimonio;
  final String observacoes;
  final String? clienteNome;

  const Equipamento({
    this.id,
    required this.clienteId,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.patrimonio,
    required this.observacoes,
    this.clienteNome,
  });

  String get rotulo => '$tipo $marca $modelo';

  Map<String, dynamic> toMap() => {
        'id': id,
        'cliente_id': clienteId,
        'tipo': tipo,
        'marca': marca,
        'modelo': modelo,
        'numero_serie': numeroSerie,
        'patrimonio': patrimonio,
        'observacoes': observacoes,
      };

  factory Equipamento.fromMap(Map<String, dynamic> map) => Equipamento(
        id: map['id'] as int?,
        clienteId: map['cliente_id'] as int,
        tipo: map['tipo'] as String,
        marca: map['marca'] as String,
        modelo: map['modelo'] as String,
        numeroSerie: map['numero_serie'] as String,
        patrimonio: map['patrimonio'] as String? ?? '',
        observacoes: map['observacoes'] as String? ?? '',
        clienteNome: map['cliente_nome'] as String?,
      );
}
