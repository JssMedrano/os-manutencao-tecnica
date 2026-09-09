/// Status do ciclo de atendimento. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
enum OsStatus {
  aberta,
  atribuida,
  emAtendimento,
  aguardandoPeca,
  concluida,
  cancelada,
}

extension OsStatusX on OsStatus {
  String get label {
    switch (this) {
      case OsStatus.aberta:
        return 'Aberta';
      case OsStatus.atribuida:
        return 'Atribuída';
      case OsStatus.emAtendimento:
        return 'Em atendimento';
      case OsStatus.aguardandoPeca:
        return 'Aguardando peça';
      case OsStatus.concluida:
        return 'Concluída';
      case OsStatus.cancelada:
        return 'Cancelada';
    }
  }

  String get dbValue => name;
}

OsStatus osStatusFromDb(String value) {
  return OsStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OsStatus.aberta,
  );
}

enum OsPrioridade { baixa, media, alta, urgente }

extension OsPrioridadeX on OsPrioridade {
  String get label {
    switch (this) {
      case OsPrioridade.baixa:
        return 'Baixa';
      case OsPrioridade.media:
        return 'Média';
      case OsPrioridade.alta:
        return 'Alta';
      case OsPrioridade.urgente:
        return 'Urgente';
    }
  }
}

OsPrioridade osPrioridadeFromDb(String value) {
  return OsPrioridade.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OsPrioridade.media,
  );
}

enum SituacaoTecnico { ativo, inativo, ferias }

extension SituacaoTecnicoX on SituacaoTecnico {
  String get label {
    switch (this) {
      case SituacaoTecnico.ativo:
        return 'Ativo';
      case SituacaoTecnico.inativo:
        return 'Inativo';
      case SituacaoTecnico.ferias:
        return 'Férias';
    }
  }
}
