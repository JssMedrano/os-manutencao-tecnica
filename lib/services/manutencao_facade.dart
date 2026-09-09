import '../core/enums.dart';
import '../models/cliente.dart';
import '../models/equipamento.dart';
import '../models/ordem_servico.dart';
import '../models/tecnico.dart';
import '../repositories/cliente_repository.dart';
import '../repositories/equipamento_repository.dart';
import '../repositories/os_repository.dart';
import '../repositories/tecnico_repository.dart';

/// Facade para operações da oficina. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ManutencaoFacade {
  ManutencaoFacade({
    ClienteRepository? clientes,
    TecnicoRepository? tecnicos,
    EquipamentoRepository? equipamentos,
    OrdemRepository? ordens,
  })  : clientes = clientes ?? ClienteRepository(),
        tecnicos = tecnicos ?? TecnicoRepository(),
        equipamentos = equipamentos ?? EquipamentoRepository(),
        ordens = ordens ?? OrdemRepository();

  final ClienteRepository clientes;
  final TecnicoRepository tecnicos;
  final EquipamentoRepository equipamentos;
  final OrdemRepository ordens;

  Future<DashboardIndicadores> indicadores() async {
    final lista = await ordens.listar();
    return DashboardIndicadores.from(lista);
  }
}

class DashboardIndicadores {
  final int total;
  final int abertas;
  final int emAtendimento;
  final int aguardandoPeca;
  final int concluidas;
  final int urgentes;
  final int atrasadas;
  final double valorTotal;

  const DashboardIndicadores({
    required this.total,
    required this.abertas,
    required this.emAtendimento,
    required this.aguardandoPeca,
    required this.concluidas,
    required this.urgentes,
    required this.atrasadas,
    required this.valorTotal,
  });

  factory DashboardIndicadores.from(List<OrdemServico> lista) {
    return DashboardIndicadores(
      total: lista.length,
      abertas: lista.where((o) => o.status == OsStatus.aberta).length,
      emAtendimento:
          lista.where((o) => o.status == OsStatus.emAtendimento).length,
      aguardandoPeca:
          lista.where((o) => o.status == OsStatus.aguardandoPeca).length,
      concluidas: lista.where((o) => o.status == OsStatus.concluida).length,
      urgentes: lista.where((o) => o.urgente).length,
      atrasadas: lista.where((o) => o.atrasada).length,
      valorTotal: lista.fold(0, (a, o) => a + o.valorTotal),
    );
  }
}

typedef Cadastros = ({
  List<Cliente> clientes,
  List<Tecnico> tecnicos,
  List<Equipamento> equipamentos,
});
