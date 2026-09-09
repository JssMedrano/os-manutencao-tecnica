import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import 'clientes_screen.dart';
import 'dashboard_screen.dart';
import 'equipamentos_screen.dart';
import 'os_list_screen.dart';
import 'tecnicos_screen.dart';

/// Navegação principal desktop/mobile. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _atrasadas = false;
  bool _urgentes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().carregarTudo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.usuario!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final destinos = [
      const _Destino('Painel', Icons.dashboard_outlined),
      const _Destino('Ordens', Icons.assignment_outlined),
      const _Destino('Clientes', Icons.apartment_outlined),
      const _Destino('Técnicos', Icons.engineering_outlined),
      const _Destino('Equipamentos', Icons.devices_other_outlined),
    ];

    final body = switch (_index) {
      0 => DashboardScreen(
          onAbrirFiltro: (status, {urgentes = false, atrasadas = false}) {
            final app = context.read<AppController>();
            app.definirFiltros(status: status, limparStatus: status == null);
            setState(() {
              _index = 1;
              _urgentes = urgentes;
              _atrasadas = atrasadas;
            });
          },
        ),
      1 => OsListScreen(somenteAtrasadas: _atrasadas, somenteUrgentes: _urgentes),
      2 => const ClientesScreen(),
      3 => const TecnicosScreen(),
      _ => const EquipamentosScreen(),
    };

    final rail = NavigationRail(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() {
        _index = i;
        _atrasadas = false;
        _urgentes = false;
      }),
      labelType: NavigationRailLabelType.all,
      destinations: destinos
          .map((d) => NavigationRailDestination(icon: Icon(d.icone), label: Text(d.label)))
          .toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user.nome} (${user.perfil})'),
        actions: [
          IconButton(
            tooltip: 'Tema',
            onPressed: auth.alternarTema,
            icon: Icon(auth.temaEscuro ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: auth.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(user.nome),
                    accountEmail: Text(user.perfil),
                    currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
                  ),
                  for (var i = 0; i < destinos.length; i++)
                    ListTile(
                      leading: Icon(destinos[i].icone),
                      title: Text(destinos[i].label),
                      selected: _index == i,
                      onTap: () {
                        setState(() => _index = i);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
      body: Row(
        children: [
          if (wide) rail,
          if (wide) const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: destinos
                  .map((d) => NavigationDestination(icon: Icon(d.icone), label: d.label))
                  .toList(),
            ),
    );
  }
}

class _Destino {
  const _Destino(this.label, this.icone);
  final String label;
  final IconData icone;
}
