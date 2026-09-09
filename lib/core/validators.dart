/// Validações de formulário. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AppValidators {
  static String? obrigatorio(String? value, [String campo = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? telefone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Telefone é obrigatório';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Telefone deve ter ao menos 10 dígitos';
    return null;
  }

  static String? documento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF/CNPJ é obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11 && digits.length != 14) {
      return 'Informe um CPF (11) ou CNPJ (14) válido';
    }
    return null;
  }

  static String? senha(String? value) {
    if (value == null || value.length < 4) {
      return 'Senha deve ter ao menos 4 caracteres';
    }
    return null;
  }

  static double? parseValor(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final normalized = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
