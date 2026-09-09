import 'package:flutter/material.dart';

import '../core/enums.dart';
import '../models/cliente.dart';
import '../models/equipamento.dart';
import '../models/historico_os.dart';
import '../models/ordem_servico.dart';
import '../models/tecnico.dart';
import '../services/manutencao_facade.dart';

/// Estado das telas principais. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AppController extends ChangeNotifier {
  AppController({ManutencaoFacade? facade})
      : facade = facade ?? ManutencaoFacade();

  final ManutencaoFacade facade;

  bool carregando = false;
  String? mensagemErro;

  List<Cliente> clientes = [];
  List<Tecnico> tecnicos = [];
  List<Equipamento> equipamentos = [];
  List<OrdemServico> ordens = [];
  DashboardIndicadores indicadores = const DashboardIndicadores(
    total: 0,
    abertas: 0,
    emAtendimento: 0,
    aguardandoPeca: 0,
    concluidas: 0,
    urgentes: 0,
    atrasadas: 0,
    valorTotal: 0,
  );

  String buscaOs = '';
  OsStatus? filtroStatus;
  OsPrioridade? filtroPrioridade;
  int? filtroTecnico;

  Future<void> carregarTudo() async {
    carregando = true;
    mensagemErro = null;
    notifyListeners();
    try {
      clientes = await facade.clientes.listar();
      tecnicos = await facade.tecnicos.listar();
      equipamentos = await facade.equipamentos.listar();
      await recarregarOrdens();
      indicadores = await facade.indicadores();
    } catch (e) {
      mensagemErro = 'Não foi possível carregar os dados. Feche e abra o aplicativo.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> recarregarOrdens() async {
    ordens = await facade.ordens.listar(
      busca: buscaOs,
      status: filtroStatus,
      prioridade: filtroPrioridade,
      tecnicoId: filtroTecnico,
    );
    indicadores = await facade.indicadores();
    notifyListeners();
  }

  void definirFiltros({
    String? busca,
    OsStatus? status,
    bool limparStatus = false,
    OsPrioridade? prioridade,
    bool limparPrioridade = false,
    int? tecnicoId,
    bool limparTecnico = false,
  }) {
    if (busca != null) buscaOs = busca;
    if (limparStatus) {
      filtroStatus = null;
    } else if (status != null) {
      filtroStatus = status;
    }
    if (limparPrioridade) {
      filtroPrioridade = null;
    } else if (prioridade != null) {
      filtroPrioridade = prioridade;
    }
    if (limparTecnico) {
      filtroTecnico = null;
    } else if (tecnicoId != null) {
      filtroTecnico = tecnicoId;
    }
    recarregarOrdens();
  }

  Future<List<HistoricoOs>> historico(int ordemId) =>
      facade.ordens.historico(ordemId);
}
