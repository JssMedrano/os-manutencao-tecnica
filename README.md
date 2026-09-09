# OS Manutenção Técnica

Aplicativo Flutter (desktop / mobile / web) para gerenciamento de **ordens de serviço** e manutenção técnica.

**Repositório:** https://github.com/JssMedrano/os-manutencao-tecnica

## Requisitos

- Flutter SDK 3.22 ou superior (`flutter doctor`)
- Windows, Linux, macOS, Android, iOS ou Web

## Como executar

```bash
cd Multiplataforma
flutter pub get
flutter run -d windows
```

Outros alvos:

```bash
flutter run -d edge      # Web
flutter run -d chrome    # Web
flutter run -d linux
flutter run -d macos
# ou um emulador Android / dispositivo iOS
```

No Windows, o primeiro uso de plugins pode exigir o Modo de desenvolvedor:

```powershell
start ms-settings:developers
```

Para compilar Windows, instale o Visual Studio com a carga **Desenvolvimento de desktop com C++**.

Na Web a persistência usa SQLite WASM (`web/sqlite3.wasm` e `web/sqflite_sw.js`). Os dados ficam no IndexedDB do navegador.

Na primeira execução em desktop o SQLite é criado em:

`Documentos/os_manutencao/os_manutencao.db`

com **12 ordens de exemplo**, clientes, técnicos e equipamentos.

## Acesso

| Usuário   | Senha | Perfil        |
|-----------|-------|---------------|
| admin     | 1234  | administrador |
| atendente | 1234  | atendente     |
| tecnico   | 1234  | técnico       |

## Funcionalidades

- Login local com perfis
- CRUD de clientes, técnicos e equipamentos (exclusão protegida por vínculos)
- OS com código único, prioridade, prazo, diagnóstico, solução e financeiro
- Fluxo de status com transições inválidas bloqueadas
- Destaque de OS **urgentes** e **atrasadas**
- Peças + mão de obra com total automático
- Imagens antes/depois
- Histórico da OS
- Dashboard com indicadores e gráfico
- Busca e filtros
- Tema claro/escuro
- Comprovante em PDF

## Estrutura

```
lib/
  models/          entidades
  screens/         telas
  widgets/         componentes
  services/        SQLite, imagens, PDF, Facade
  repositories/    persistência
  controllers/     estado (Provider)
  core/            tema, validações, State da OS, Factory
```

Padrões: **Repository**, **Singleton**, **Factory Method**, **State**, **Facade**.

## Persistência

SQLite via `sqflite` (mobile), `sqflite_common_ffi` (desktop) e `sqflite_common_ffi_web` (navegador).

## Testes

```bash
flutter analyze
flutter test
```

## Entrega acadêmica

- **Relatório final para submissão:** `docs/Relatorio_OS_Manutencao.docx`
- Documentação: `DOCUMENTACAO.md`
- Prints (opcional): `docs/screenshots/`

Para regenerar o relatório:

```bash
cd docs
npm install
node gerar_relatorio.mjs
```
