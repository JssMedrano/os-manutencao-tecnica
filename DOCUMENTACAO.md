# Documentação do Projeto

## Sistema de Ordem de Serviço e Manutenção Técnica

**Disciplina:** Desenvolvimento Multiplataforma Desktop  
**Tecnologia:** Flutter + Dart + SQLite  
**Prazo de entrega:** 11 de setembro de 2026  
**Repositório:** https://github.com/JssMedrano/os-manutencao-tecnica  

> Documento único do projeto. O arquivo oficial de submissão no Univirtus é  
> `docs/Relatorio_OS_Manutencao.docx` (documentação, wireframes, análise crítica  
> e código-fonte completo com indentação preservada).

---

## 1. Problema a ser resolvido

Empresas de manutenção técnica controlam atendimentos em papéis, planilhas e
mensagens. Isso gera atraso, perda de histórico, duplicidade de chamados e
dificuldade para localizar equipamentos. O aplicativo centraliza clientes,
técnicos, equipamentos e ordens de serviço, permitindo acompanhar o atendimento
da abertura até a conclusão.

## 2. Objetivo geral

Desenvolver um aplicativo mobile/desktop em Flutter para gerenciamento de
ordens de serviço e manutenção técnica, contemplando cadastro, consulta,
edição, exclusão, fluxo de atendimento, persistência local e indicadores
operacionais.

## 3. Objetivos específicos atendidos

| Objetivo | Situação |
|----------|----------|
| Cadastrar e listar clientes | Implementado |
| Cadastrar e listar técnicos | Implementado |
| Cadastrar equipamentos vinculados a clientes | Implementado |
| Abrir nova ordem de serviço | Implementado |
| Editar e consultar OS completa | Implementado |
| Atribuir prioridade, técnico, prazo e status | Implementado |
| Registrar problema, diagnóstico e solução | Implementado |
| Registrar peças, quantidade, valores e mão de obra | Implementado |
| Calcular total automaticamente | Implementado |
| Anexar imagens (antes/depois) | Implementado |
| Buscar por número, cliente, equipamento ou técnico | Implementado |
| Filtrar por status, prioridade e responsável | Implementado |
| Painel com indicadores | Implementado |
| Persistência após fechar o aplicativo | Implementado (SQLite) |

## 4. Funcionalidades obrigatórias

### Autenticação
Login local com hash SHA-256. Três perfis: administrador, atendente e técnico.  
Usuários de demonstração: `admin`, `atendente`, `tecnico` — senha `1234`.

### Cadastros
- **Clientes:** nome, CPF/CNPJ, telefone, e-mail, endereço (CRUD com exclusão protegida).
- **Técnicos:** nome, contato, especialidade, situação (ativo/inativo/férias).
- **Equipamentos:** vinculados ao cliente; tipo, marca, modelo, série, patrimônio, observações.

### Ordem de serviço
Código único (`OS-2026-NNNN`), cliente, equipamento, problema, prioridade,
técnico, datas, status, diagnóstico, solução, financeiro, evidências e histórico.

### Fluxo de status (padrão State)
```
Aberta          → Atribuída, Cancelada
Atribuída       → Em atendimento, Cancelada, Aberta
Em atendimento  → Aguardando peça, Concluída, Cancelada
Aguardando peça → Em atendimento, Cancelada
Concluída / Cancelada → estados finais
```
- Conclusão exige diagnóstico ou solução.
- Atribuição exige técnico responsável.
- Transições inválidas são impedidas com mensagem ao usuário.

### Prioridade e prazos
Baixa, Média, Alta, Urgente. Ordens atrasadas (prazo < hoje e status aberto)
e urgentes são destacadas na lista e no painel.

### Financeiro
Mão de obra + lista de peças (descrição, quantidade, valor unitário).  
Total = mão de obra + Σ(quantidade × valor unitário).

### Imagens
Evidências antes e depois (arquivo, galeria ou câmera). Em web e desktop as
imagens são persistidas como data URI; em mobile também há suporte a câmera.

### Dashboard
Total, abertas, em atendimento, aguardando peça, concluídas, urgentes,
atrasadas e valor total registrado, com gráfico de barras.

### Busca e filtros
Busca por número, cliente, equipamento ou técnico. Filtros por status,
prioridade e técnico responsável.

### Persistência
SQLite relacional:
- Desktop: `sqflite_common_ffi`
- Mobile: `sqflite`
- Web: `sqflite_common_ffi_web` (WASM + IndexedDB)

## 5. Arquitetura e organização do código

```
lib/
  main.dart / app.dart
  core/           tema, enums, validações, OsStatusMachine, AtendimentoFactory
  models/         Cliente, Tecnico, Equipamento, OrdemServico, ItemOs, HistoricoOs, Usuario
  repositories/   acesso SQL
  services/       DatabaseService, ImageService, PdfService, ManutencaoFacade, factories SQLite
  controllers/    AuthController, AppController (Provider)
  widgets/        KPI, chips, feedback, evidências
  screens/        login, painel, OS, clientes, técnicos, equipamentos
```

### Padrões aplicados (funcionais)

| Padrão | Classe | Função real |
|--------|--------|-------------|
| Repository | `*Repository` | Isola SQL das telas |
| Singleton | `DatabaseService.instance` | Uma conexão SQLite |
| Factory Method | `AtendimentoFactory` | Tipo de atendimento + prazo padrão |
| State | `OsStatusMachine` | Ciclo e transições da OS |
| Facade | `ManutencaoFacade` | Indicadores do painel |

### Gerenciamento de estado
Provider com `AuthController` (sessão e tema) e `AppController` (listas,
filtros e indicadores).

## 6. Dados de exemplo

Na primeira execução o banco cria:
- 5 clientes
- 4 técnicos
- 8 equipamentos
- **12 ordens de serviço** em status e prioridades variados (incluindo urgentes e atrasadas)

## 7. Wireframes

```
LOGIN          → cartão central com usuário, senha e Entrar
PAINEL         → KPIs + gráfico + NavigationRail/Drawer
LISTA DE OS    → busca, filtros, cards com chips, FAB Nova OS
DETALHE DA OS  → dados, financeiro, fotos, status, histórico, PDF
CADASTROS      → ListTile + formulários validados + exclusão confirmada
```

## 8. Plataformas

| Plataforma | Situação |
|------------|----------|
| Windows | Testado e funcional |
| Web (Chrome/Edge) | Funcional (SQLite WASM) |
| Android / iOS | Suportado pelo código |
| Linux / macOS | Suportado pelo código (FFI) |

## 9. Diferenciais opcionais implementados

- Comprovante da OS em PDF
- Tema claro e escuro
- Gráfico no painel (`fl_chart`)
- Funcionamento em Web além de desktop/mobile

## 10. Como executar

```bash
flutter pub get
flutter run -d windows
# ou
flutter run -d edge
```

Acesso: `admin` / `1234`.

## 11. Análise crítica

**Funcionalidades.** Login com perfis, CRUDs, ciclo da OS, financeiro com total
automático, evidências, histórico, dashboard, busca/filtros, PDF, tema
claro/escuro e persistência SQLite multiplataforma (incluindo Web).

**Dificuldades.** Persistência desktop exigiu FFI; Web exigiu
`sqflite_common_ffi_web` e evidências sem `dart:io`; exclusões precisaram
bloquear vínculos para evitar inconsistência.

**Decisões.** Camadas (models/repositories/services/controllers/screens);
Provider; SQLite relacional; cinco padrões aplicados de forma real.

**Limitações.** Sem Firebase, sem mapa, sem assinatura digital, sem estoque
independente, sem sincronização em nuvem.

**Melhorias futuras.** Notificações de prazo, mapa do atendimento, assinatura
do cliente, exportação CSV, estoque de peças e painéis por técnico/período.

## 12. Entregáveis

| Entregável | Local |
|------------|-------|
| Relatório final (.docx) | `docs/Relatorio_OS_Manutencao.docx` |
| Documentação | `DOCUMENTACAO.md` (este arquivo) |
| README | `README.md` |
| Código-fonte | `lib/` |
| Dependências | `pubspec.yaml` |
| Repositório GitHub | https://github.com/JssMedrano/os-manutencao-tecnica |
| Testes | `test/widget_test.dart` |

## 13. Conformidade com os critérios de avaliação

| Critério | Peso | Atendimento |
|----------|------|-------------|
| Interface e usabilidade | 10% | Material 3, NavigationRail/Drawer, Cards, formulários, SnackBar, AlertDialog |
| Funcionalidades obrigatórias | 20% | Clientes, técnicos, equipamentos, OS completa |
| CRUD e fluxo da OS | 15% | CRUD + OsStatusMachine com bloqueio de transições inválidas |
| Persistência | 10% | SQLite com FKs; dados sobrevivem ao fechar o app |
| Regras de negócio e financeiro | 20% | Vínculos, atrasos, prioridades, total automático |
| Busca, filtros, dashboard e evidências | 10% | Implementados |

Comentários no código: **TAMANDUÁ-BANDEIRA UM BICHO LEGAL**.
