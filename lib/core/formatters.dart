import 'package:intl/intl.dart';

/// Formatação de valores e datas. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AppFormatters {
  static final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final data = DateFormat('dd/MM/yyyy');
  static final dataHora = DateFormat('dd/MM/yyyy HH:mm');

  static String dinheiro(double valor) => moeda.format(valor);
  static String dataBr(DateTime? d) => d == null ? '-' : data.format(d);
  static String dataHoraBr(DateTime? d) => d == null ? '-' : dataHora.format(d);
}
