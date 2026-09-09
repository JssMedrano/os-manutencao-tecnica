import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/enums.dart';
import '../core/formatters.dart';
import '../core/os_status_machine.dart';
import '../models/ordem_servico.dart';
import '../services/image_service.dart';
import '../services/pdf_service.dart';
import '../widgets/evidence_image.dart';
import '../widgets/feedback.dart';
import '../widgets/status_chip.dart';
import 'os_form_screen.dart';

/// Detalhe, fluxo, evidências e histórico. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OsDetailScreen extends StatefulWidget {
  const OsDetailScreen({super.key, required this.ordemId});
  final int ordemId;

  @override
  State<OsDetailScreen> createState() => _OsDetailScreenState();
}

class _OsDetailScreenState extends State<OsDetailScreen> {
  final _imagens = ImageService();
  final _pdf = PdfService();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final encontradas = app.ordens.where((o) => o.id == widget.ordemId);
    final os = encontradas.isEmpty ? null : encontradas.first;
    if (os == null) {
      return const Scaffold(body: Center(child: Text('Ordem não encontrada.')));
    }
    final proximos = OsStatusMachine.proximos(os.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(os.codigo),
        actions: [
          IconButton(
            tooltip: 'PDF',
            onPressed: () => _pdf.imprimirOs(os),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OsFormScreen(ordem: os)),
              );
              if (context.mounted) await context.read<AppController>().carregarTudo();
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: () async {
              final ok = await confirmarExclusao(
                context,
                titulo: 'Excluir OS',
                mensagem: 'Excluir ${os.codigo}? O histórico também será removido.',
              );
              if (!ok || !context.mounted) return;
              await app.facade.ordens.excluir(os.id!);
              if (!context.mounted) return;
              snackOk(context, 'Ordem excluída.');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(spacing: 8, children: [
            StatusChip(status: os.status),
            PrioridadeChip(prioridade: os.prioridade),
            if (os.atrasada)
              const Chip(label: Text('ATRASADA'), backgroundColor: Color(0x33E65100)),
          ]),
          const SizedBox(height: 12),
          _linha('Cliente', os.clienteNome ?? ''),
          _linha('Equipamento', os.equipamentoRotulo ?? ''),
          _linha('Técnico', os.tecnicoNome ?? 'não atribuído'),
          _linha('Tipo', os.tipoAtendimento),
          _linha('Abertura', AppFormatters.dataHoraBr(os.dataAbertura)),
          _linha('Prazo', AppFormatters.dataBr(os.dataLimite)),
          _linha('Conclusão', AppFormatters.dataBr(os.dataConclusao)),
          const Divider(),
          _bloco('Problema', os.descricaoProblema),
          _bloco('Diagnóstico', os.diagnostico.isEmpty ? '-' : os.diagnostico),
          _bloco('Solução', os.solucao.isEmpty ? '-' : os.solucao),
          const Divider(),
          Text('Financeiro', style: Theme.of(context).textTheme.titleMedium),
          ...os.itens.map((i) => ListTile(
                dense: true,
                title: Text(i.descricao),
                trailing: Text(AppFormatters.dinheiro(i.subtotal)),
              )),
          _linha('Mão de obra', AppFormatters.dinheiro(os.valorMaoObra)),
          _linha('Peças', AppFormatters.dinheiro(os.valorPecas)),
          _linha('TOTAL', AppFormatters.dinheiro(os.valorTotal)),
          const Divider(),
          Text('Evidências', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(child: _fotoBox('Antes', os.imagemAntes, (p) => _salvarFoto(os, antes: p))),
              const SizedBox(width: 8),
              Expanded(child: _fotoBox('Depois', os.imagemDepois, (p) => _salvarFoto(os, depois: p))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final p = await _imagens.selecionarArquivo();
                  if (p != null) await _salvarFoto(os, antes: p);
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria / arquivo (antes)'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final p = await _imagens.capturarCamera();
                  if (p != null) await _salvarFoto(os, depois: p);
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Câmera (depois)'),
              ),
            ],
          ),
          const Divider(),
          Text('Alterar status', style: Theme.of(context).textTheme.titleMedium),
          if (proximos.isEmpty)
            const Text('Esta OS está encerrada e não admite novas transições.')
          else
            Wrap(
              spacing: 8,
              children: proximos
                  .map(
                    (s) => FilledButton.tonal(
                      onPressed: () => _status(os, s),
                      child: Text(s.label),
                    ),
                  )
                  .toList(),
            ),
          const Divider(),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          FutureBuilder(
            future: app.historico(os.id!),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: snap.data!
                    .map(
                      (h) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.timeline),
                        title: Text(h.descricao),
                        subtitle: Text('${h.usuario} · ${AppFormatters.dataHoraBr(h.dataHora)}'),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _linha(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 130, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(v)),
          ],
        ),
      );

  Widget _bloco(String t, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(v),
          ],
        ),
      );

  Widget _fotoBox(String titulo, String? path, Future<void> Function(String) onNovo) {
    return Column(
      children: [
        Text(titulo),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: EvidenceImage(stored: path),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _salvarFoto(OrdemServico os, {String? antes, String? depois}) async {
    final usuario = context.read<AuthController>().usuario?.nome ?? 'Usuário';
    final atualizada = os.copyWith(
      imagemAntes: antes ?? os.imagemAntes,
      imagemDepois: depois ?? os.imagemDepois,
    );
    await context.read<AppController>().facade.ordens.salvar(atualizada, usuario: usuario);
    if (mounted) {
      await context.read<AppController>().carregarTudo();
      if (mounted) snackOk(context, 'Evidência anexada.');
    }
  }

  Future<void> _status(OrdemServico os, OsStatus novo) async {
    final usuario = context.read<AuthController>().usuario?.nome ?? 'Usuário';
    final erro = await context.read<AppController>().facade.ordens.alterarStatus(
          os: os,
          novo: novo,
          usuario: usuario,
        );
    if (!mounted) return;
    if (erro != null) {
      snackErro(context, erro);
    } else {
      snackOk(context, 'Status atualizado para ${novo.label}.');
      await context.read<AppController>().carregarTudo();
    }
  }
}
