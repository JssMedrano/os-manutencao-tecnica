import '../core/enums.dart';
import 'item_os.dart';

/// Ordem de serviço completa. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OrdemServico {
  final int? id;
  final String codigo;
  final int clienteId;
  final int equipamentoId;
  final int? tecnicoId;
  final String tipoAtendimento;
  final String descricaoProblema;
  final String diagnostico;
  final String solucao;
  final OsPrioridade prioridade;
  final OsStatus status;
  final DateTime dataAbertura;
  final DateTime? dataLimite;
  final DateTime? dataConclusao;
  final double valorMaoObra;
  final String? imagemAntes;
  final String? imagemDepois;
  final String? clienteNome;
  final String? equipamentoRotulo;
  final String? tecnicoNome;
  final List<ItemOs> itens;

  const OrdemServico({
    this.id,
    required this.codigo,
    required this.clienteId,
    required this.equipamentoId,
    this.tecnicoId,
    required this.tipoAtendimento,
    required this.descricaoProblema,
    this.diagnostico = '',
    this.solucao = '',
    required this.prioridade,
    required this.status,
    required this.dataAbertura,
    this.dataLimite,
    this.dataConclusao,
    this.valorMaoObra = 0,
    this.imagemAntes,
    this.imagemDepois,
    this.clienteNome,
    this.equipamentoRotulo,
    this.tecnicoNome,
    this.itens = const [],
  });

  double get valorPecas =>
      itens.fold(0, (acc, item) => acc + item.subtotal);

  double get valorTotal => valorMaoObra + valorPecas;

  bool get atrasada {
    if (status == OsStatus.concluida || status == OsStatus.cancelada) {
      return false;
    }
    if (dataLimite == null) return false;
    final hoje = DateTime.now();
    final limite = DateTime(
      dataLimite!.year,
      dataLimite!.month,
      dataLimite!.day,
    );
    final hojeDia = DateTime(hoje.year, hoje.month, hoje.day);
    return limite.isBefore(hojeDia);
  }

  bool get urgente => prioridade == OsPrioridade.urgente;

  OrdemServico copyWith({
    int? id,
    String? codigo,
    int? clienteId,
    int? equipamentoId,
    int? tecnicoId,
    bool limparTecnico = false,
    String? tipoAtendimento,
    String? descricaoProblema,
    String? diagnostico,
    String? solucao,
    OsPrioridade? prioridade,
    OsStatus? status,
    DateTime? dataAbertura,
    DateTime? dataLimite,
    DateTime? dataConclusao,
    double? valorMaoObra,
    String? imagemAntes,
    String? imagemDepois,
    List<ItemOs>? itens,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      clienteId: clienteId ?? this.clienteId,
      equipamentoId: equipamentoId ?? this.equipamentoId,
      tecnicoId: limparTecnico ? null : (tecnicoId ?? this.tecnicoId),
      tipoAtendimento: tipoAtendimento ?? this.tipoAtendimento,
      descricaoProblema: descricaoProblema ?? this.descricaoProblema,
      diagnostico: diagnostico ?? this.diagnostico,
      solucao: solucao ?? this.solucao,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataLimite: dataLimite ?? this.dataLimite,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      valorMaoObra: valorMaoObra ?? this.valorMaoObra,
      imagemAntes: imagemAntes ?? this.imagemAntes,
      imagemDepois: imagemDepois ?? this.imagemDepois,
      clienteNome: clienteNome,
      equipamentoRotulo: equipamentoRotulo,
      tecnicoNome: tecnicoNome,
      itens: itens ?? this.itens,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'codigo': codigo,
        'cliente_id': clienteId,
        'equipamento_id': equipamentoId,
        'tecnico_id': tecnicoId,
        'tipo_atendimento': tipoAtendimento,
        'descricao_problema': descricaoProblema,
        'diagnostico': diagnostico,
        'solucao': solucao,
        'prioridade': prioridade.name,
        'status': status.name,
        'data_abertura': dataAbertura.toIso8601String(),
        'data_limite': dataLimite?.toIso8601String(),
        'data_conclusao': dataConclusao?.toIso8601String(),
        'valor_mao_obra': valorMaoObra,
        'imagem_antes': imagemAntes,
        'imagem_depois': imagemDepois,
      };

  factory OrdemServico.fromMap(
    Map<String, dynamic> map, {
    List<ItemOs> itens = const [],
  }) {
    return OrdemServico(
      id: map['id'] as int?,
      codigo: map['codigo'] as String,
      clienteId: map['cliente_id'] as int,
      equipamentoId: map['equipamento_id'] as int,
      tecnicoId: map['tecnico_id'] as int?,
      tipoAtendimento: map['tipo_atendimento'] as String? ?? 'corretiva',
      descricaoProblema: map['descricao_problema'] as String,
      diagnostico: map['diagnostico'] as String? ?? '',
      solucao: map['solucao'] as String? ?? '',
      prioridade: osPrioridadeFromDb(map['prioridade'] as String),
      status: osStatusFromDb(map['status'] as String),
      dataAbertura: DateTime.parse(map['data_abertura'] as String),
      dataLimite: map['data_limite'] == null
          ? null
          : DateTime.parse(map['data_limite'] as String),
      dataConclusao: map['data_conclusao'] == null
          ? null
          : DateTime.parse(map['data_conclusao'] as String),
      valorMaoObra: (map['valor_mao_obra'] as num?)?.toDouble() ?? 0,
      imagemAntes: map['imagem_antes'] as String?,
      imagemDepois: map['imagem_depois'] as String?,
      clienteNome: map['cliente_nome'] as String?,
      equipamentoRotulo: map['equipamento_rotulo'] as String?,
      tecnicoNome: map['tecnico_nome'] as String?,
      itens: itens,
    );
  }
}
