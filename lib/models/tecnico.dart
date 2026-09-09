import '../core/enums.dart';

/// Técnico responsável. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class Tecnico {
  final int? id;
  final String nome;
  final String contato;
  final String especialidade;
  final SituacaoTecnico situacao;

  const Tecnico({
    this.id,
    required this.nome,
    required this.contato,
    required this.especialidade,
    required this.situacao,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'contato': contato,
        'especialidade': especialidade,
        'situacao': situacao.name,
      };

  factory Tecnico.fromMap(Map<String, dynamic> map) => Tecnico(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        contato: map['contato'] as String,
        especialidade: map['especialidade'] as String,
        situacao: SituacaoTecnico.values.firstWhere(
          (e) => e.name == map['situacao'],
          orElse: () => SituacaoTecnico.ativo,
        ),
      );
}
