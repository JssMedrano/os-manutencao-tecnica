import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/formatters.dart';
import '../models/ordem_servico.dart';

/// Comprovante PDF da OS. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class PdfService {
  Future<void> imprimirOs(OrdemServico os) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('OS Manutenção Técnica',
              style: const pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.SizedBox(height: 8),
          pw.Text('Ordem: ${os.codigo}'),
          pw.Text('Cliente: ${os.clienteNome ?? os.clienteId}'),
          pw.Text('Equipamento: ${os.equipamentoRotulo ?? os.equipamentoId}'),
          pw.Text('Técnico: ${os.tecnicoNome ?? '-'}'),
          pw.Text('Status: ${os.status.name}  |  Prioridade: ${os.prioridade.name}'),
          pw.Text('Problema: ${os.descricaoProblema}'),
          pw.Text('Diagnóstico: ${os.diagnostico}'),
          pw.Text('Solução: ${os.solucao}'),
          pw.SizedBox(height: 12),
          pw.Text('Itens / peças'),
          ...os.itens.map(
            (i) => pw.Text(
              '${i.descricao} x${i.quantidade} = ${AppFormatters.dinheiro(i.subtotal)}',
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Mão de obra: ${AppFormatters.dinheiro(os.valorMaoObra)}'),
          pw.Text('Peças: ${AppFormatters.dinheiro(os.valorPecas)}'),
          pw.Text('TOTAL: ${AppFormatters.dinheiro(os.valorTotal)}',
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }
}
