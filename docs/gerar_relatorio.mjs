// Gerador do relatorio .docx do trabalho academico.
// TAMANDUA-BANDEIRA UM BICHO LEGAL
import {
  Document,
  Packer,
  Paragraph,
  TextRun,
  HeadingLevel,
  PageBreak,
  AlignmentType,
  Table,
  TableRow,
  TableCell,
  WidthType,
  ImageRun,
  BorderStyle,
} from "docx";
import { readFileSync, writeFileSync, readdirSync, existsSync, statSync } from "fs";
import { dirname, join, relative, extname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");

const BODY_FONT = "Calibri";
const CODE_FONT = "Consolas";

function p(text, opts = {}) {
  const { bold = false, italics = false, size = 22, align, spacing = 140 } = opts;
  return new Paragraph({
    alignment: align,
    spacing: { after: spacing },
    children: [new TextRun({ text, font: BODY_FONT, size, bold, italics })],
  });
}

function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 180 },
    children: [new TextRun({ text, font: BODY_FONT, bold: true, size: 32 })],
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 260, after: 140 },
    children: [new TextRun({ text, font: BODY_FONT, bold: true, size: 26 })],
  });
}

function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 200, after: 100 },
    children: [new TextRun({ text, font: CODE_FONT, bold: true, size: 22 })],
  });
}

function bullet(text) {
  return new Paragraph({
    bullet: { level: 0 },
    spacing: { after: 60 },
    children: [new TextRun({ text, font: BODY_FONT, size: 22 })],
  });
}

// Cada linha vira um paragrafo proprio com fonte monoespacada.
// Os espacos iniciais sao mantidos porque a lib escreve xml:space="preserve".
function codeLine(line) {
  return new Paragraph({
    spacing: { after: 0, line: 200, lineRule: "auto" },
    children: [
      new TextRun({
        text: line.length === 0 ? " " : line.replace(/\t/g, "    "),
        font: CODE_FONT,
        size: 15,
      }),
    ],
  });
}

function codeBlock(content) {
  return content.replace(/\r\n/g, "\n").split("\n").map(codeLine);
}

function tabela(linhas) {
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: linhas.map(
      (celulas, idx) =>
        new TableRow({
          children: celulas.map(
            (texto) =>
              new TableCell({
                margins: { top: 60, bottom: 60, left: 100, right: 100 },
                children: [
                  new Paragraph({
                    children: [
                      new TextRun({
                        text: texto,
                        font: BODY_FONT,
                        size: 20,
                        bold: idx === 0,
                      }),
                    ],
                  }),
                ],
              })
          ),
        })
    ),
  });
}

function separador() {
  return new Paragraph({
    spacing: { after: 160 },
    border: {
      bottom: { style: BorderStyle.SINGLE, size: 6, color: "AAAAAA", space: 1 },
    },
    children: [new TextRun({ text: "" })],
  });
}

function listarDart(dir) {
  const saida = [];
  for (const nome of readdirSync(dir)) {
    const caminho = join(dir, nome);
    if (statSync(caminho).isDirectory()) {
      saida.push(...listarDart(caminho));
    } else if (extname(nome) === ".dart") {
      saida.push(caminho);
    }
  }
  return saida;
}

// Ordem didatica: entrada, core, models, repositories, services, controllers,
// widgets e por fim as telas.
const PESO_PASTA = {
  "lib": 0,
  "lib\\core": 1,
  "lib/core": 1,
  "lib\\models": 2,
  "lib/models": 2,
  "lib\\repositories": 3,
  "lib/repositories": 3,
  "lib\\services": 4,
  "lib/services": 4,
  "lib\\controllers": 5,
  "lib/controllers": 5,
  "lib\\widgets": 6,
  "lib/widgets": 6,
  "lib\\screens": 7,
  "lib/screens": 7,
};

const arquivosDart = listarDart(join(ROOT, "lib")).sort((a, b) => {
  const ra = relative(ROOT, a);
  const rb = relative(ROOT, b);
  const pa = PESO_PASTA[dirname(ra)] ?? 9;
  const pb = PESO_PASTA[dirname(rb)] ?? 9;
  if (pa !== pb) return pa - pb;
  return ra.localeCompare(rb);
});

// Conteudo textual do relatorio embutido no gerador, para que o projeto
// entregue nao dependa de arquivos markdown auxiliares.
const WIREFRAMES = [
  "1. LOGIN / IDENTIFICACAO",
  "+------------------------------------------+",
  "|            [icone chave inglesa]         |",
  "|          OS Manutencao Tecnica           |",
  "|   Usuario: [ admin                  ]    |",
  "|   Senha:   [ ****                   ]    |",
  "|            [       Entrar           ]    |",
  "|   admin / atendente / tecnico  senha 1234|",
  "+------------------------------------------+",
  "",
  "2. PAINEL (DASHBOARD)",
  "+--------+---------------------------------------------+",
  "| Painel | Total   | Abertas  | Atendim. | Aguard. peca |",
  "| Ordens | Concl.  | Urgentes | Atrasadas| Valor total  |",
  "| Client.|                                             |",
  "| Tecnic.| [ grafico de barras dos indicadores ]       |",
  "| Equip. |                                             |",
  "+--------+---------------------------------------------+",
  "",
  "3. LISTA DE OS (BUSCA E FILTROS)",
  "+-------------------------------------------------------+",
  "| [ Buscar: numero, cliente, equipamento ou tecnico    ] |",
  "| [Status v] [Prioridade v] [Tecnico v]                  |",
  "|                                                        |",
  "| OS-2026-0006 . Mercado Bom Preco                       |",
  "| Freezer Consul CHB53CB                                 |",
  "| Tecnico: Ana Souza . Prazo 09/09/2026                  |",
  "| Total R$ 300,00                                        |",
  "| [Em atendimento] [Urgente] [ATRASADA]                  |",
  "|                                        [ + Nova OS ]   |",
  "+-------------------------------------------------------+",
  "",
  "4. DETALHE / FLUXO DA OS",
  "+-------------------------------------------------------+",
  "| < OS-2026-0003            [PDF] [Editar] [Excluir]     |",
  "| [Em atendimento] [Urgente]                             |",
  "| Cliente / Equipamento / Tecnico / Tipo / Prazo         |",
  "| Problema | Diagnostico | Solucao                       |",
  "| Financeiro: itens + mao de obra = TOTAL                |",
  "| Evidencias: [ foto antes ]   [ foto depois ]           |",
  "| Alterar status: [Aguardando peca] [Concluida] [Cancel] |",
  "| Historico: linha do tempo das alteracoes               |",
  "+-------------------------------------------------------+",
  "",
  "5. CADASTROS (CLIENTE / TECNICO / EQUIPAMENTO)",
  "+-------------------------------------------------------+",
  "| Lista em Cards com ListTile e acoes de editar/excluir  |",
  "| Formulario com TextFormField validado e Dropdown       |",
  "| Exclusao confirmada em AlertDialog                     |",
  "|                                    [ + Novo registro ] |",
  "+-------------------------------------------------------+",
].join("\n");

const EVIDENCIAS = [
  "Login: entrar com admin e senha 1234. Fechar o aplicativo e abrir novamente: os dados continuam disponiveis.",
  "Persistencia: cadastrar um cliente de teste, fechar o aplicativo, reabrir e conferir que o registro permanece na lista.",
  "Abertura de OS: cliente e equipamento sao obrigatorios; o total e recalculado a cada peca incluida.",
  "Fluxo invalido: tentar mudar de Aberta direto para Concluida. O sistema recusa a transicao e exibe mensagem.",
  "Fluxo valido: Aberta para Atribuida (com tecnico), depois Em atendimento e por fim Concluida (com diagnostico preenchido).",
  "Atraso: as ordens OS-2026-0005 e OS-2026-0006 nascem com prazo vencido e aparecem destacadas como atrasadas.",
  "Urgencia: as ordens OS-2026-0003 e OS-2026-0006 possuem prioridade Urgente e recebem destaque visual.",
  "Exclusao protegida: tentar excluir o cliente Padaria Estrela, que possui equipamentos e ordens vinculadas. A operacao e bloqueada.",
  "Imagens: no detalhe da OS, anexar um arquivo como evidencia antes e capturar ou selecionar a evidencia depois.",
  "Relatorio: gerar o comprovante em PDF pelo botao da barra superior do detalhe.",
  "Tema: alternar entre claro e escuro pelo icone da AppBar; a preferencia e mantida entre execucoes.",
];

const ANALISE = [
  [
    "Funcionalidades implementadas",
    "Foram entregues a autenticacao local com tres perfis (administrador, atendente e tecnico), o CRUD completo de clientes, tecnicos e equipamentos, o ciclo completo da ordem de servico com controle de transicoes, o controle financeiro com calculo automatico do total, o anexo de evidencias fotograficas antes e depois, o historico de alteracoes, o painel com indicadores e grafico, a busca com filtros por status, prioridade e tecnico, o tema claro e escuro e a geracao de comprovante em PDF. Toda a informacao e persistida em SQLite local, inclusive no navegador.",
  ],
  [
    "Dificuldades encontradas",
    "A persistencia desktop exigiu sqflite_common_ffi e troca da databaseFactory em Windows, Linux e macOS. Na Web foi necessario adotar sqflite_common_ffi_web (WASM + IndexedDB) e eliminar dependencias de dart:io nas evidencias, persistindo imagens como data URI. Tambem exigiu atencao modelar as transicoes de status para exibir apenas acoes validas e bloquear exclusoes que gerariam registros orfaos, sem expor mensagens tecnicas do banco ao usuario.",
  ],
  [
    "Decisoes tecnicas e arquiteturais",
    "O projeto foi dividido em camadas (core, models, repositories, services, controllers, widgets e screens), deixando o main.dart apenas com a inicializacao. Optou-se por Provider em vez de Bloc, por manter o fluxo de estado explicito. Os padroes Repository, Singleton, Factory Method, State e Facade foram aplicados de forma funcional. Factories condicionais (sqlite_factory e evidence_bytes) isolam o codigo especifico de Web e de IO nativo.",
  ],
  [
    "Tecnologia de persistencia",
    "Foi utilizado SQLite, conforme recomendacao do enunciado. Em desktop o arquivo fica em Documentos/os_manutencao/os_manutencao.db; em mobile usa o plugin nativo; na Web a mesma API SQL e atendida por WASM gravado no IndexedDB. Chaves estrangeiras ativas, exclusao em cascata para itens e historico, e exclusao restrita para cadastros com vinculo.",
  ],
  [
    "Gerenciamento de estado",
    "Dois ChangeNotifier controlam a aplicacao. O AuthController cuida da sessao e do tema (shared_preferences). O AppController mantem listas, filtros e indicadores, recalculados pela ManutencaoFacade. As telas observam com context.watch e disparam acoes com context.read.",
  ],
  [
    "Limitacoes da versao entregue",
    "A autenticacao e local (SHA-256), sem Firebase e sem recuperacao de senha. Nao ha sincronizacao em nuvem nem uso simultaneo multiusuario. Geolocalizacao, assinatura digital e estoque independente de pecas nao foram implementados. Os dados da Web ficam no IndexedDB do navegador e nao sao compartilhados com o banco desktop.",
  ],
  [
    "Melhorias para versoes futuras",
    "Notificacoes de prazo e de ordens atrasadas, sincronizacao offline com servidor, mapa do atendimento, assinatura do cliente, exportacao CSV, modulo de estoque e graficos de desempenho por tecnico e periodo.",
  ],
];

const screenshotsDir = join(__dirname, "screenshots");
const legendas = {
  "01-login.png": "Tela de login / identificacao do usuario (perfis admin, atendente e tecnico).",
  "02-dashboard.png": "Painel com indicadores operacionais e grafico de barras.",
  "03-ordens.png": "Lista de ordens de servico com busca e filtros por status, prioridade e tecnico.",
  "04-detalhe.png": "Detalhe da OS: financeiro, evidencias, transicoes de status e historico.",
  "05-clientes.png": "Cadastro de clientes com edicao e exclusao protegida por vinculos.",
  "06-tecnicos.png": "Cadastro de tecnicos com especialidade e situacao.",
  "07-equipamentos.png": "Cadastro de equipamentos vinculados ao cliente.",
  "08-nova-os.png": "Formulario de abertura de OS com calculo automatico do total.",
};

function blocoScreenshots() {
  if (!existsSync(screenshotsDir)) {
    return [
      p(
        "As capturas de tela estao na pasta docs/screenshots do projeto.",
        { italics: true }
      ),
    ];
  }
  const imagens = readdirSync(screenshotsDir)
    .filter((f) => f.toLowerCase().endsWith(".png"))
    .sort();
  if (imagens.length === 0) {
    return [p("Nenhuma captura disponivel.", { italics: true })];
  }
  const filhos = [];
  for (const nome of imagens) {
    filhos.push(
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 160, after: 60 },
        children: [
          new ImageRun({
            type: "png",
            data: readFileSync(join(screenshotsDir, nome)),
            transformation: { width: 600, height: 338 },
          }),
        ],
      })
    );
    filhos.push(
      p(legendas[nome] ?? nome, {
        italics: true,
        size: 18,
        align: AlignmentType.CENTER,
        spacing: 220,
      })
    );
  }
  return filhos;
}

const capa = [
  p("Centro Universitario Internacional", { align: AlignmentType.CENTER, bold: true }),
  p("Desenvolvimento Multiplataforma Desktop", { align: AlignmentType.CENTER }),
  new Paragraph({ spacing: { after: 800 }, children: [new TextRun("")] }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 200 },
    children: [
      new TextRun({
        text: "Sistema de Ordem de Servico e Manutencao Tecnica",
        font: BODY_FONT,
        bold: true,
        size: 44,
      }),
    ],
  }),
  p("Aplicativo Flutter (desktop, mobile e web) com persistencia SQLite", {
    align: AlignmentType.CENTER,
    italics: true,
  }),
  p("Repositorio: https://github.com/JssMedrano/os-manutencao-tecnica", {
    align: AlignmentType.CENTER,
  }),
  new Paragraph({ spacing: { after: 1000 }, children: [new TextRun("")] }),
  p("Trabalho academico individual", { align: AlignmentType.CENTER }),
  p("Entrega: 11 de setembro de 2026", { align: AlignmentType.CENTER }),
  new Paragraph({ children: [new PageBreak()] }),
];

const sumario = [
  h1("Sumario"),
  bullet("1. Descricao do projeto e objetivos"),
  bullet("2. Problema a ser resolvido"),
  bullet("3. Tecnologias utilizadas e dependencias (pubspec.yaml)"),
  bullet("4. Arquitetura, organizacao de pastas e padroes de projeto"),
  bullet("5. Regras de negocio implementadas"),
  bullet("6. Fluxo da ordem de servico"),
  bullet("7. Wireframes das telas principais"),
  bullet("8. Prints do sistema em execucao"),
  bullet("9. Evidencias de persistencia e das funcionalidades"),
  bullet("10. Instrucoes de configuracao e execucao (README)"),
  bullet("11. Analise critica do desenvolvimento"),
  bullet("12. Codigo-fonte completo"),
  new Paragraph({ children: [new PageBreak()] }),
];

const conteudo = [
  h1("1. Descricao do projeto e objetivos"),
  p(
    "Este trabalho apresenta um aplicativo multiplataforma desenvolvido em Flutter para o gerenciamento de ordens de servico e manutencao tecnica. A solucao atende uma empresa que presta servicos de manutencao em computadores, servidores, impressoras, aparelhos de climatizacao e outros ativos, acompanhando o atendimento desde a abertura da solicitacao ate a conclusao do servico."
  ),
  p(
    "O aplicativo centraliza clientes, tecnicos, equipamentos e ordens de servico, substituindo planilhas, formularios impressos e mensagens dispersas por um cadastro unico, com indicadores operacionais, controle financeiro, evidencias fotograficas e historico de cada atendimento."
  ),
  h2("Objetivo geral"),
  p(
    "Desenvolver um aplicativo mobile/desktop em Flutter para gerenciamento de ordens de servico e manutencao tecnica, contemplando cadastro, consulta, edicao, exclusao, acompanhamento do fluxo de atendimento, persistencia local e apresentacao de indicadores operacionais."
  ),
  h2("Objetivos especificos atendidos"),
  bullet("Cadastrar e listar clientes."),
  bullet("Cadastrar e listar tecnicos responsaveis pelos atendimentos."),
  bullet("Cadastrar equipamentos ou ativos vinculados aos clientes."),
  bullet("Abrir uma nova ordem de servico com codigo unico."),
  bullet("Editar e consultar os dados completos de uma ordem de servico."),
  bullet("Atribuir prioridade, tecnico responsavel, prazo e status."),
  bullet("Registrar descricao do problema, diagnostico e solucao aplicada."),
  bullet("Registrar pecas, materiais, quantidade, valores e mao de obra."),
  bullet("Calcular automaticamente o valor total da ordem de servico."),
  bullet("Anexar ou selecionar imagens relacionadas ao atendimento."),
  bullet("Buscar ordens por numero, cliente, equipamento ou tecnico."),
  bullet("Filtrar ordens por status, prioridade e responsavel."),
  bullet("Apresentar painel com indicadores e resumo das ordens."),
  bullet("Manter os dados salvos apos o fechamento do aplicativo."),

  h1("2. Problema a ser resolvido"),
  p(
    "Empresas de manutencao tecnica precisam controlar diversos atendimentos simultaneamente. Quando essas informacoes ficam espalhadas em papeis, planilhas ou conversas, ocorrem atrasos, perda de dados, dificuldade para localizar equipamentos, duplicidade de chamados, falhas na comunicacao com clientes e ausencia de historico tecnico."
  ),
  p(
    "O sistema desenvolvido permite registrar, consultar e acompanhar todas as etapas do atendimento de forma organizada, respondendo rapidamente quais ordens estao abertas, em andamento, aguardando peca ou finalizadas, qual cliente e equipamento estao relacionados, qual tecnico e responsavel, qual o prazo, quais pecas foram utilizadas, qual o diagnostico e qual o custo total."
  ),

  h1("3. Tecnologias utilizadas e dependencias"),
  tabela([
    ["Recurso", "Tecnologia adotada"],
    ["Interface", "Flutter com Material 3 (MaterialApp, Scaffold, AppBar, NavigationRail, Drawer, Cards, ListTile)"],
    ["Linguagem", "Dart 3"],
    ["Gerenciamento de estado", "Provider (ChangeNotifier)"],
    ["Persistencia", "SQLite via sqflite e sqflite_common_ffi (desktop)"],
    ["Imagens e evidencias", "file_picker e image_picker"],
    ["Relatorio da OS", "pdf e printing"],
    ["Graficos do painel", "fl_chart"],
    ["Preferencias do usuario", "shared_preferences (tema claro/escuro)"],
    ["Seguranca do login", "crypto (hash SHA-256 da senha)"],
  ]),
  h2("Arquivo pubspec.yaml"),
  ...codeBlock(readFileSync(join(ROOT, "pubspec.yaml"), "utf8")),

  h1("4. Arquitetura, organizacao de pastas e padroes de projeto"),
  p(
    "O sistema nao concentra codigo no arquivo main.dart. A responsabilidade de cada camada esta isolada em pastas proprias, conforme exigido pelo enunciado:"
  ),
  ...codeBlock(
    [
      "lib/",
      "  main.dart          ponto de entrada (apenas inicializacao)",
      "  app.dart           MaterialApp, tema e providers",
      "  core/              tema, constantes, enums, validacoes,",
      "                     maquina de estados da OS e factory de atendimento",
      "  models/            Cliente, Tecnico, Equipamento, OrdemServico,",
      "                     ItemOs, HistoricoOs e Usuario",
      "  repositories/      acesso e persistencia dos dados (SQL)",
      "  services/          banco de dados, imagens, PDF e facade",
      "  controllers/       gerenciamento de estado e regras da interface",
      "  widgets/           componentes visuais reutilizaveis",
      "  screens/           telas do aplicativo",
    ].join("\n")
  ),
  h2("Padroes de projeto aplicados"),
  tabela([
    ["Padrao", "Onde foi aplicado", "Funcao real no sistema"],
    [
      "Repository",
      "ClienteRepository, TecnicoRepository, EquipamentoRepository, OrdemRepository",
      "Isola o SQL das telas e centraliza as regras de integridade na exclusao",
    ],
    [
      "Singleton",
      "DatabaseService.instance",
      "Garante uma unica conexao SQLite e uma unica criacao do schema",
    ],
    [
      "Factory Method",
      "AtendimentoFactory",
      "Cria o tipo de atendimento (corretiva, preventiva, emergencia, instalacao) e define o prazo padrao de cada um",
    ],
    [
      "State",
      "OsStatusMachine",
      "Controla o ciclo de vida da OS e bloqueia transicoes invalidas",
    ],
    [
      "Facade",
      "ManutencaoFacade",
      "Reune os repositorios e calcula os indicadores do painel numa unica interface",
    ],
  ]),
  h2("Gerenciamento de estado"),
  p(
    "Foram usados dois ChangeNotifier: AuthController, responsavel pela sessao do usuario e pelo tema claro/escuro, e AppController, que mantem as listas de clientes, tecnicos, equipamentos e ordens, alem dos filtros ativos e dos indicadores do painel. As telas observam o estado com context.watch e disparam acoes com context.read."
  ),

  h1("5. Regras de negocio implementadas"),
  bullet("Toda ordem de servico esta obrigatoriamente vinculada a um cliente e a um equipamento."),
  bullet("O codigo da OS e unico e sequencial, no formato OS-2026-NNNN, com restricao UNIQUE no banco."),
  bullet("Toda OS possui prioridade (Baixa, Media, Alta ou Urgente) e status."),
  bullet("Uma OS em aberto cuja data limite seja anterior a data atual e identificada como atrasada e destacada na lista e no painel."),
  bullet("O valor total e calculado automaticamente: mao de obra somada ao total das pecas (quantidade multiplicada pelo valor unitario de cada item)."),
  bullet("O historico de cada OS e gravado em tabela propria e permanece salvo."),
  bullet("Transicoes de status invalidas sao impedidas e o usuario recebe mensagem explicando o motivo."),
  bullet("A OS so pode ser concluida se houver diagnostico ou solucao registrada."),
  bullet("A OS so pode ser atribuida se houver tecnico responsavel selecionado."),
  bullet("A exclusao de cliente, equipamento ou tecnico e bloqueada quando existem registros vinculados, evitando inconsistencia."),
  bullet("Itens e historico sao removidos em cascata quando a propria OS e excluida."),
  h2("Tratamento de erros e validacoes"),
  bullet("Campos obrigatorios nao podem ser gravados vazios (validator em todos os TextFormField)."),
  bullet("Valores numericos sao convertidos e validados antes do calculo."),
  bullet("E-mail e telefone possuem validacao por expressao regular e contagem minima de digitos."),
  bullet("CPF/CNPJ exige 11 ou 14 digitos."),
  bullet("Exclusoes sao confirmadas em AlertDialog antes de executar."),
  bullet("Excecoes tecnicas nao aparecem para o usuario: sao capturadas e substituidas por mensagens em SnackBar."),

  h1("6. Fluxo da ordem de servico"),
  p(
    "O ciclo de atendimento foi implementado com o padrao State na classe OsStatusMachine. O mapa de transicoes define exatamente quais mudancas sao permitidas a partir de cada estado:"
  ),
  ...codeBlock(
    [
      "Aberta          -> Atribuida, Cancelada",
      "Atribuida       -> Em atendimento, Cancelada, Aberta",
      "Em atendimento  -> Aguardando peca, Concluida, Cancelada",
      "Aguardando peca -> Em atendimento, Cancelada",
      "Concluida       -> (estado final)",
      "Cancelada       -> (estado final)",
    ].join("\n")
  ),
  p(
    "Na tela de detalhe, apenas os botoes das transicoes validas sao exibidos. Se a regra adicional falhar (concluir sem diagnostico, ou atribuir sem tecnico), a operacao e recusada e uma mensagem explicativa e apresentada."
  ),

  h1("7. Wireframes das telas principais"),
  p(
    "Os esbocos abaixo representam o protótipo das telas antes da implementacao. A navegacao usa NavigationRail em telas largas (desktop) e Drawer com NavigationBar em telas estreitas (mobile)."
  ),
  ...codeBlock(WIREFRAMES),

  h1("8. Prints do sistema em execucao"),
  ...blocoScreenshots(),

  h1("9. Evidencias de persistencia e das funcionalidades"),
  p(
    "Os dados sao gravados em SQLite. No desktop o arquivo fica em Documentos/os_manutencao/os_manutencao.db; no mobile usa o plugin nativo; na Web a mesma API SQL e atendida por WASM + IndexedDB (arquivos web/sqlite3.wasm e web/sqflite_sw.js). As chaves estrangeiras sao ativadas com PRAGMA foreign_keys = ON."
  ),
  h2("Roteiro de testes para validacao"),
  ...EVIDENCIAS.map(bullet),
  h2("Dados de exemplo carregados"),
  p(
    "A carga inicial cria 5 clientes, 4 tecnicos, 8 equipamentos e 12 ordens de servico distribuidas entre todos os status e todas as prioridades, incluindo ordens urgentes e ordens atrasadas, atendendo o minimo de dez ordens pedido no enunciado."
  ),

  h1("10. Instrucoes de configuracao e execucao"),
  ...codeBlock(readFileSync(join(ROOT, "README.md"), "utf8")),

  h1("11. Analise critica do desenvolvimento"),
  ...ANALISE.flatMap(([titulo, texto]) => [h2(titulo), p(texto)]),
];

const codigo = [
  new Paragraph({ children: [new PageBreak()] }),
  h1("12. Codigo-fonte completo"),
  p(
    `O projeto possui ${arquivosDart.length} arquivos Dart na pasta lib, alem dos testes automatizados. Todos os arquivos sao reproduzidos abaixo com a indentacao original preservada. O comando flutter analyze nao acusa nenhum problema e os testes automatizados passam integralmente.`
  ),
];

for (const arquivo of arquivosDart) {
  const rel = relative(ROOT, arquivo).replace(/\\/g, "/");
  codigo.push(h3(rel));
  codigo.push(separador());
  codigo.push(...codeBlock(readFileSync(arquivo, "utf8")));
  codigo.push(p(""));
}

const testes = join(ROOT, "test", "widget_test.dart");
if (existsSync(testes)) {
  codigo.push(h2("Testes automatizados"));
  codigo.push(h3("test/widget_test.dart"));
  codigo.push(separador());
  codigo.push(...codeBlock(readFileSync(testes, "utf8")));
}

codigo.push(
  p(
    "Observacao: conforme solicitado no enunciado, todos os arquivos de codigo possuem em seus comentarios a marcacao TAMANDUA-BANDEIRA UM BICHO LEGAL.",
    { italics: true }
  )
);

const doc = new Document({
  creator: "Trabalho academico - Desenvolvimento Multiplataforma Desktop",
  title: "Sistema de Ordem de Servico e Manutencao Tecnica",
  description: "Aplicativo Flutter com persistencia SQLite",
  sections: [
    {
      properties: {
        page: { margin: { top: 1000, bottom: 1000, left: 1000, right: 1000 } },
      },
      children: [...capa, ...sumario, ...conteudo, ...codigo],
    },
  ],
});

const out = join(__dirname, "Relatorio_OS_Manutencao.docx");
const buf = await Packer.toBuffer(doc);
writeFileSync(out, buf);
console.log(`Gerado: ${out}`);
console.log(`Arquivos Dart incluidos: ${arquivosDart.length}`);
