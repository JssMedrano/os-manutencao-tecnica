import 'package:flutter_test/flutter_test.dart';
import 'package:os_manutencao/core/enums.dart';
import 'package:os_manutencao/core/atendimento_factory.dart';
import 'package:os_manutencao/core/os_status_machine.dart';
import 'package:os_manutencao/core/validators.dart';
import 'package:os_manutencao/models/item_os.dart';
import 'package:os_manutencao/models/ordem_servico.dart';

void main() {
  test('fluxo da OS impede concluir direto de aberta', () {
    expect(OsStatusMachine.podeTransitar(OsStatus.aberta, OsStatus.concluida), isFalse);
    expect(OsStatusMachine.podeTransitar(OsStatus.aberta, OsStatus.atribuida), isTrue);
  });

  test('conclusão exige diagnóstico ou solução', () {
    expect(
      OsStatusMachine.validarConclusao(diagnostico: '', solucao: ''),
      isNotNull,
    );
    expect(
      OsStatusMachine.validarConclusao(diagnostico: 'Fonte queimada', solucao: ''),
      isNull,
    );
  });

  test('e-mail e telefone', () {
    expect(AppValidators.email('a@b.com'), isNull);
    expect(AppValidators.email('x'), isNotNull);
    expect(AppValidators.telefone('41988887777'), isNull);
  });

  test('total da OS soma mão de obra e itens', () {
    final os = OrdemServico(
      codigo: 'OS-2026-9999',
      clienteId: 1,
      equipamentoId: 1,
      tipoAtendimento: 'corretiva',
      descricaoProblema: 'Falha',
      prioridade: OsPrioridade.alta,
      status: OsStatus.aberta,
      dataAbertura: DateTime(2026, 9, 9),
      valorMaoObra: 150,
      itens: const [
        ItemOs(
          ordemId: 1,
          descricao: 'Fonte',
          quantidade: 2,
          valorUnitario: 75,
        ),
      ],
    );

    expect(os.valorPecas, 150);
    expect(os.valorTotal, 300);
  });

  test('OS vencida não inclui concluída ou cancelada', () {
    final prazo = DateTime.now().subtract(const Duration(days: 1));
    OrdemServico criar(OsStatus status) => OrdemServico(
          codigo: 'OS-2026-9999',
          clienteId: 1,
          equipamentoId: 1,
          tipoAtendimento: 'corretiva',
          descricaoProblema: 'Falha',
          prioridade: OsPrioridade.media,
          status: status,
          dataAbertura: DateTime.now(),
          dataLimite: prazo,
        );

    expect(criar(OsStatus.aberta).atrasada, isTrue);
    expect(criar(OsStatus.concluida).atrasada, isFalse);
    expect(criar(OsStatus.cancelada).atrasada, isFalse);
  });

  test('factory define prazo por tipo de atendimento', () {
    expect(
      AtendimentoFactory.criar('preventiva').prazoPadrao,
      const Duration(days: 7),
    );
    expect(
      AtendimentoFactory.criar('emergencia').prazoPadrao,
      const Duration(hours: 24),
    );
  });
}
