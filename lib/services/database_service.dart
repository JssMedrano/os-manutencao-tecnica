import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/constants.dart';
import 'sqlite_factory.dart';

/// Singleton do SQLite (desktop/mobile/web). TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  static String hashSenha(String senha) {
    return sha256.convert(senha.codeUnits).toString();
  }

  Future<Database> _open() async {
    await initSqliteFactory();
    final path = await resolveSqlitePath(AppConstants.dbName);
    debugPrint('Banco SQLite: $path');

    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
        onOpen: _ensureDefaultUsers,
      ),
    );
  }

  Future<void> _ensureDefaultUsers(Database db) async {
    final usuarios = [
      {
        'nome': 'Administrador',
        'login': 'admin',
        'senha_hash': hashSenha('1234'),
        'perfil': 'administrador',
        'tecnico_id': null,
      },
      {
        'nome': 'Marina Atendente',
        'login': 'atendente',
        'senha_hash': hashSenha('1234'),
        'perfil': 'atendente',
        'tecnico_id': null,
      },
      {
        'nome': 'Carlos Mendes',
        'login': 'tecnico',
        'senha_hash': hashSenha('1234'),
        'perfil': 'tecnico',
        'tecnico_id': 1,
      },
    ];
    for (final usuario in usuarios) {
      await db.insert(
        'usuarios',
        usuario,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        login TEXT NOT NULL UNIQUE,
        senha_hash TEXT NOT NULL,
        perfil TEXT NOT NULL,
        tecnico_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        documento TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT NOT NULL,
        endereco TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tecnicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        contato TEXT NOT NULL,
        especialidade TEXT NOT NULL,
        situacao TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE equipamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        numero_serie TEXT NOT NULL,
        patrimonio TEXT,
        observacoes TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute('''
      CREATE TABLE ordens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        cliente_id INTEGER NOT NULL,
        equipamento_id INTEGER NOT NULL,
        tecnico_id INTEGER,
        tipo_atendimento TEXT NOT NULL,
        descricao_problema TEXT NOT NULL,
        diagnostico TEXT,
        solucao TEXT,
        prioridade TEXT NOT NULL,
        status TEXT NOT NULL,
        data_abertura TEXT NOT NULL,
        data_limite TEXT,
        data_conclusao TEXT,
        valor_mao_obra REAL NOT NULL DEFAULT 0,
        imagem_antes TEXT,
        imagem_depois TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
        FOREIGN KEY (equipamento_id) REFERENCES equipamentos(id) ON DELETE RESTRICT,
        FOREIGN KEY (tecnico_id) REFERENCES tecnicos(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE itens_os (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ordem_id INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        quantidade REAL NOT NULL,
        valor_unitario REAL NOT NULL,
        FOREIGN KEY (ordem_id) REFERENCES ordens(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE historico_os (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ordem_id INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        usuario TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        FOREIGN KEY (ordem_id) REFERENCES ordens(id) ON DELETE CASCADE
      )
    ''');

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final hash = hashSenha('1234');

    await db.insert('tecnicos', {
      'nome': 'Carlos Mendes',
      'contato': '41988881111',
      'especialidade': 'Informática / PCs',
      'situacao': 'ativo',
    });
    await db.insert('tecnicos', {
      'nome': 'Ana Souza',
      'contato': '41988882222',
      'especialidade': 'Climatização',
      'situacao': 'ativo',
    });
    await db.insert('tecnicos', {
      'nome': 'Rafael Lima',
      'contato': '41988883333',
      'especialidade': 'Máquinas industriais',
      'situacao': 'ferias',
    });
    await db.insert('tecnicos', {
      'nome': 'Juliana Costa',
      'contato': '41988884444',
      'especialidade': 'Eletrônica / aparelhos',
      'situacao': 'ativo',
    });

    await db.insert('usuarios', {
      'nome': 'Administrador',
      'login': 'admin',
      'senha_hash': hash,
      'perfil': 'administrador',
      'tecnico_id': null,
    });
    await db.insert('usuarios', {
      'nome': 'Marina Atendente',
      'login': 'atendente',
      'senha_hash': hash,
      'perfil': 'atendente',
      'tecnico_id': null,
    });
    await db.insert('usuarios', {
      'nome': 'Carlos Mendes',
      'login': 'tecnico',
      'senha_hash': hash,
      'perfil': 'tecnico',
      'tecnico_id': 1,
    });

    final clientes = [
      {
        'nome': 'Padaria Estrela',
        'documento': '12345678000190',
        'telefone': '4133331001',
        'email': 'contato@padariaestrela.com',
        'endereco': 'Rua das Flores, 120 - Centro',
      },
      {
        'nome': 'Clínica Vida Nova',
        'documento': '22345678000191',
        'telefone': '4133331002',
        'email': 'ti@vidanova.com',
        'endereco': 'Av. Saúde, 450 - Batel',
      },
      {
        'nome': 'João Pedro Almeida',
        'documento': '12345678901',
        'telefone': '41999990003',
        'email': 'joao.almeida@email.com',
        'endereco': 'Rua Paraná, 88 - Água Verde',
      },
      {
        'nome': 'Mercado Bom Preço',
        'documento': '32345678000192',
        'telefone': '4133331004',
        'email': 'compras@bompreco.com',
        'endereco': 'Rua do Comércio, 10 - Portão',
      },
      {
        'nome': 'Escritório Contábil Silva',
        'documento': '42345678000193',
        'telefone': '4133331005',
        'email': 'admin@contabilsilva.com',
        'endereco': 'Rua XV de Novembro, 900 - Centro',
      },
    ];
    for (final c in clientes) {
      await db.insert('clientes', c);
    }

    final equipamentos = [
      {
        'cliente_id': 1,
        'tipo': 'Computador',
        'marca': 'Dell',
        'modelo': 'OptiPlex 7090',
        'numero_serie': 'DL-7090-001',
        'patrimonio': 'PAT-1001',
        'observacoes': 'PDV principal',
      },
      {
        'cliente_id': 1,
        'tipo': 'Ar-condicionado',
        'marca': 'Springer',
        'modelo': 'Split 12000',
        'numero_serie': 'SP-AC-120',
        'patrimonio': 'PAT-1002',
        'observacoes': 'Salão',
      },
      {
        'cliente_id': 2,
        'tipo': 'Servidor',
        'marca': 'HP',
        'modelo': 'ProLiant ML30',
        'numero_serie': 'HP-ML30-77',
        'patrimonio': 'PAT-2001',
        'observacoes': 'Prontuário eletrônico',
      },
      {
        'cliente_id': 2,
        'tipo': 'Impressora',
        'marca': 'Brother',
        'modelo': 'HL-L6200',
        'numero_serie': 'BR-6200-02',
        'patrimonio': 'PAT-2002',
        'observacoes': 'Recepção',
      },
      {
        'cliente_id': 3,
        'tipo': 'Notebook',
        'marca': 'Lenovo',
        'modelo': 'ThinkPad T14',
        'numero_serie': 'LN-T14-009',
        'patrimonio': 'PESSOAL',
        'observacoes': 'Uso doméstico/trabalho',
      },
      {
        'cliente_id': 4,
        'tipo': 'Freezer',
        'marca': 'Consul',
        'modelo': 'CHB53CB',
        'numero_serie': 'CS-FRZ-441',
        'patrimonio': 'PAT-4001',
        'observacoes': 'Açougue',
      },
      {
        'cliente_id': 4,
        'tipo': 'Computador',
        'marca': 'Positivo',
        'modelo': 'Master N100',
        'numero_serie': 'PS-N100-12',
        'patrimonio': 'PAT-4002',
        'observacoes': 'Caixa 2',
      },
      {
        'cliente_id': 5,
        'tipo': 'Nobreak',
        'marca': 'SMS',
        'modelo': 'Station II 1200',
        'numero_serie': 'SMS-1200-55',
        'patrimonio': 'PAT-5001',
        'observacoes': 'Sala servidores',
      },
    ];
    for (final e in equipamentos) {
      await db.insert('equipamentos', e);
    }

    final now = DateTime.now();
    String iso(DateTime d) => d.toIso8601String();

    Future<void> os({
      required String codigo,
      required int cliente,
      required int eq,
      int? tec,
      required String tipo,
      required String problema,
      String diag = '',
      String sol = '',
      required String prioridade,
      required String status,
      required DateTime abertura,
      DateTime? limite,
      DateTime? conclusao,
      double mao = 0,
      List<Map<String, dynamic>> itens = const [],
      required String hist,
    }) async {
      final id = await db.insert('ordens', {
        'codigo': codigo,
        'cliente_id': cliente,
        'equipamento_id': eq,
        'tecnico_id': tec,
        'tipo_atendimento': tipo,
        'descricao_problema': problema,
        'diagnostico': diag,
        'solucao': sol,
        'prioridade': prioridade,
        'status': status,
        'data_abertura': iso(abertura),
        'data_limite': limite == null ? null : iso(limite),
        'data_conclusao': conclusao == null ? null : iso(conclusao),
        'valor_mao_obra': mao,
      });
      for (final item in itens) {
        await db.insert('itens_os', {
          'ordem_id': id,
          ...item,
        });
      }
      await db.insert('historico_os', {
        'ordem_id': id,
        'descricao': hist,
        'usuario': 'Sistema (dados de exemplo)',
        'data_hora': iso(abertura),
      });
    }

    await os(
      codigo: 'OS-2026-0001',
      cliente: 1,
      eq: 1,
      tec: 1,
      tipo: 'corretiva',
      problema: 'PDV não liga após queda de energia.',
      diag: 'Fonte danificada.',
      sol: 'Troca da fonte 500W.',
      prioridade: 'alta',
      status: 'concluida',
      abertura: now.subtract(const Duration(days: 20)),
      limite: now.subtract(const Duration(days: 17)),
      conclusao: now.subtract(const Duration(days: 18)),
      mao: 180,
      itens: [
        {'descricao': 'Fonte ATX 500W', 'quantidade': 1, 'valor_unitario': 320}
      ],
      hist: 'OS concluída com troca de fonte.',
    );
    await os(
      codigo: 'OS-2026-0002',
      cliente: 1,
      eq: 2,
      tec: 2,
      tipo: 'preventiva',
      problema: 'Ar-condicionado com ruído e baixa refrigeração.',
      prioridade: 'media',
      status: 'aguardandoPeca',
      abertura: now.subtract(const Duration(days: 5)),
      limite: now.add(const Duration(days: 2)),
      mao: 150,
      itens: [
        {'descricao': 'Capacitor 45uF', 'quantidade': 1, 'valor_unitario': 85}
      ],
      hist: 'Aguardando capacitor de reposição.',
    );
    await os(
      codigo: 'OS-2026-0003',
      cliente: 2,
      eq: 3,
      tec: 1,
      tipo: 'emergencia',
      problema: 'Servidor reiniciando sozinho.',
      prioridade: 'urgente',
      status: 'emAtendimento',
      abertura: now.subtract(const Duration(days: 1)),
      limite: now,
      mao: 450,
      hist: 'Técnico em atendimento de emergência.',
    );
    await os(
      codigo: 'OS-2026-0004',
      cliente: 2,
      eq: 4,
      tec: 4,
      tipo: 'corretiva',
      problema: 'Impressora atolando papel.',
      prioridade: 'media',
      status: 'atribuida',
      abertura: now.subtract(const Duration(days: 2)),
      limite: now.add(const Duration(days: 1)),
      mao: 90,
      hist: 'Atribuída à técnica Juliana.',
    );
    await os(
      codigo: 'OS-2026-0005',
      cliente: 3,
      eq: 5,
      tipo: 'corretiva',
      problema: 'Notebook superaquecendo e desligando.',
      prioridade: 'alta',
      status: 'aberta',
      abertura: now.subtract(const Duration(days: 4)),
      limite: now.subtract(const Duration(days: 1)),
      hist: 'OS aberta, ainda sem técnico.',
    );
    await os(
      codigo: 'OS-2026-0006',
      cliente: 4,
      eq: 6,
      tec: 2,
      tipo: 'emergencia',
      problema: 'Freezer do açougue sem refrigerar.',
      prioridade: 'urgente',
      status: 'emAtendimento',
      abertura: now.subtract(const Duration(hours: 8)),
      limite: now.subtract(const Duration(hours: 2)),
      mao: 300,
      hist: 'Urgente e já atrasada — priorizar.',
    );
    await os(
      codigo: 'OS-2026-0007',
      cliente: 4,
      eq: 7,
      tec: 1,
      tipo: 'corretiva',
      problema: 'Caixa não reconhece leitor de código.',
      prioridade: 'media',
      status: 'concluida',
      abertura: now.subtract(const Duration(days: 12)),
      limite: now.subtract(const Duration(days: 10)),
      conclusao: now.subtract(const Duration(days: 11)),
      diag: 'USB do leitor com mau contato.',
      sol: 'Substituição do cabo e porta USB.',
      mao: 120,
      itens: [
        {'descricao': 'Cabo USB reforçado', 'quantidade': 1, 'valor_unitario': 45}
      ],
      hist: 'Concluída.',
    );
    await os(
      codigo: 'OS-2026-0008',
      cliente: 5,
      eq: 8,
      tec: 4,
      tipo: 'preventiva',
      problema: 'Troca preventiva de baterias do nobreak.',
      prioridade: 'baixa',
      status: 'aguardandoPeca',
      abertura: now.subtract(const Duration(days: 6)),
      limite: now.add(const Duration(days: 4)),
      mao: 80,
      itens: [
        {'descricao': 'Bateria 12V 7Ah', 'quantidade': 2, 'valor_unitario': 95}
      ],
      hist: 'Peças pedidas ao fornecedor.',
    );
    await os(
      codigo: 'OS-2026-0009',
      cliente: 5,
      eq: 8,
      tipo: 'instalacao',
      problema: 'Instalar segundo nobreak na sala de arquivos.',
      prioridade: 'baixa',
      status: 'aberta',
      abertura: now.subtract(const Duration(days: 1)),
      limite: now.add(const Duration(days: 5)),
      hist: 'Aguardando agendamento.',
    );
    await os(
      codigo: 'OS-2026-0010',
      cliente: 3,
      eq: 5,
      tec: 4,
      tipo: 'corretiva',
      problema: 'Tela com linhas verticais.',
      prioridade: 'alta',
      status: 'cancelada',
      abertura: now.subtract(const Duration(days: 15)),
      limite: now.subtract(const Duration(days: 12)),
      hist: 'Cliente optou por não seguir com o reparo.',
    );
    await os(
      codigo: 'OS-2026-0011',
      cliente: 2,
      eq: 3,
      tec: 1,
      tipo: 'preventiva',
      problema: 'Limpeza e atualização de firmware do servidor.',
      prioridade: 'media',
      status: 'atribuida',
      abertura: now.subtract(const Duration(hours: 20)),
      limite: now.add(const Duration(days: 3)),
      mao: 250,
      hist: 'Manutenção preventiva agendada.',
    );
    await os(
      codigo: 'OS-2026-0012',
      cliente: 1,
      eq: 1,
      tec: 1,
      tipo: 'corretiva',
      problema: 'Sistema do PDV lento após atualização.',
      prioridade: 'alta',
      status: 'emAtendimento',
      abertura: now.subtract(const Duration(hours: 6)),
      limite: now.add(const Duration(days: 1)),
      mao: 160,
      hist: 'Em atendimento no local.',
    );
  }
}
