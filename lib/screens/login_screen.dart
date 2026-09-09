import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../core/theme.dart';
import '../core/validators.dart';

/// Tela inicial de identificação. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _login = TextEditingController(text: 'admin');
  final _senha = TextEditingController(text: '1234');
  bool _ocultar = true;
  bool _enviando = false;

  @override
  void dispose() {
    _login.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    final auth = context.read<AuthController>();
    final ok = await auth.login(_login.text.trim().toLowerCase(), _senha.text);
    if (!mounted) return;
    setState(() => _enviando = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.erro ?? 'Falha no acesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.navy, AppTheme.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.build_circle, size: 56, color: AppTheme.navy),
                      const SizedBox(height: 8),
                      Text(
                        'OS Manutenção Técnica',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Identifique-se para acompanhar as ordens de serviço.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _login,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => AppValidators.obrigatorio(v, 'Usuário'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senha,
                        obscureText: _ocultar,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _ocultar = !_ocultar),
                            icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: AppValidators.senha,
                        onFieldSubmitted: (_) => _entrar(),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _enviando ? null : _entrar,
                        child: _enviando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Entrar'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Perfis de demonstração (senha 1234):\n'
                        'admin · atendente · tecnico',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
