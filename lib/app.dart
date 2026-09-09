import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

/// MaterialApp da oficina. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OsManutencaoApp extends StatelessWidget {
  const OsManutencaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return MaterialApp(
      title: 'OS Manutenção Técnica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: auth.temaEscuro ? ThemeMode.dark : ThemeMode.light,
      home: auth.usuario == null ? const LoginScreen() : const HomeShell(),
    );
  }
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()..carregarPreferencias()),
        ChangeNotifierProvider(create: (_) => AppController()),
      ],
      child: const OsManutencaoApp(),
    );
  }
}
