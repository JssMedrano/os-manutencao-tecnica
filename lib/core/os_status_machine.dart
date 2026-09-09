import 'enums.dart';

/// Padrão State: transições válidas do ciclo da OS.
/// TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OsStatusMachine {
  static const Map<OsStatus, Set<OsStatus>> transicoes = {
    OsStatus.aberta: {OsStatus.atribuida, OsStatus.cancelada},
    OsStatus.atribuida: {
      OsStatus.emAtendimento,
      OsStatus.cancelada,
      OsStatus.aberta,
    },
    OsStatus.emAtendimento: {
      OsStatus.aguardandoPeca,
      OsStatus.concluida,
      OsStatus.cancelada,
    },
    OsStatus.aguardandoPeca: {
      OsStatus.emAtendimento,
      OsStatus.cancelada,
    },
    OsStatus.concluida: {},
    OsStatus.cancelada: {},
  };

  static bool podeTransitar(OsStatus atual, OsStatus destino) {
    return transicoes[atual]?.contains(destino) ?? false;
  }

  static List<OsStatus> proximos(OsStatus atual) {
    return transicoes[atual]?.toList() ?? const [];
  }

  /// Conclusão exige diagnóstico ou solução mínima.
  static String? validarConclusao({
    required String diagnostico,
    required String solucao,
  }) {
    if (diagnostico.trim().isEmpty && solucao.trim().isEmpty) {
      return 'Para concluir a OS, informe o diagnóstico ou a solução aplicada.';
    }
    return null;
  }

  static String? validarAtribuicao(int? tecnicoId) {
    if (tecnicoId == null) {
      return 'Selecione um técnico responsável antes de atribuir a OS.';
    }
    return null;
  }
}
