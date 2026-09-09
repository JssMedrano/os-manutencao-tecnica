import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

/// Estado de autenticação e tema. TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AuthController extends ChangeNotifier {
  AuthController({UsuarioRepository? repo})
      : _repo = repo ?? UsuarioRepository();

  final UsuarioRepository _repo;
  Usuario? usuario;
  bool temaEscuro = false;
  String? erro;

  Future<void> carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    temaEscuro = prefs.getBool('tema_escuro') ?? false;
    notifyListeners();
  }

  Future<void> alternarTema() async {
    temaEscuro = !temaEscuro;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', temaEscuro);
    notifyListeners();
  }

  Future<bool> login(String login, String senha) async {
    erro = null;
    try {
      usuario = await _repo.autenticar(login, senha);
      if (usuario == null) {
        erro = 'Usuário ou senha inválidos.';
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      erro = 'Não foi possível autenticar. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    usuario = null;
    notifyListeners();
  }
}
