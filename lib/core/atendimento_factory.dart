/// Padrão Factory Method para tipos de atendimento.
/// TAMANDUÁ-BANDEIRA UM BICHO LEGAL
abstract class TipoAtendimento {
  String get codigo;
  String get descricao;
  Duration get prazoPadrao;
}

class AtendimentoPreventiva implements TipoAtendimento {
  @override
  String get codigo => 'preventiva';
  @override
  String get descricao => 'Manutenção preventiva';
  @override
  Duration get prazoPadrao => const Duration(days: 7);
}

class AtendimentoCorretiva implements TipoAtendimento {
  @override
  String get codigo => 'corretiva';
  @override
  String get descricao => 'Manutenção corretiva';
  @override
  Duration get prazoPadrao => const Duration(days: 3);
}

class AtendimentoEmergencia implements TipoAtendimento {
  @override
  String get codigo => 'emergencia';
  @override
  String get descricao => 'Atendimento de emergência';
  @override
  Duration get prazoPadrao => const Duration(hours: 24);
}

class AtendimentoInstalacao implements TipoAtendimento {
  @override
  String get codigo => 'instalacao';
  @override
  String get descricao => 'Instalação / implantação';
  @override
  Duration get prazoPadrao => const Duration(days: 5);
}

class AtendimentoFactory {
  static TipoAtendimento criar(String codigo) {
    switch (codigo) {
      case 'preventiva':
        return AtendimentoPreventiva();
      case 'emergencia':
        return AtendimentoEmergencia();
      case 'instalacao':
        return AtendimentoInstalacao();
      case 'corretiva':
      default:
        return AtendimentoCorretiva();
    }
  }

  static List<TipoAtendimento> todos() => [
        AtendimentoCorretiva(),
        AtendimentoPreventiva(),
        AtendimentoEmergencia(),
        AtendimentoInstalacao(),
      ];
}
