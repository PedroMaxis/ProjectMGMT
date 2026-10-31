# Dados fictícios da demonstração: pessoas, produtos, projetos, tarefas, páginas e comentários.
module Dados
  USUARIOS = [
    [ :marina, "Marina Costa", "Gerente de Produto", "admin", "#7c3aed" ],
    [ :rafael, "Rafael Lima", "Tech Lead", "member", "#0d9488" ],
    [ :camila, "Camila Duarte", "Designer de Produto", "member", "#db2777" ],
    [ :bruno, "Bruno Tavares", "Engenheiro de Backend", "member", "#ea580c" ],
    [ :juliana, "Juliana Prado", "Engenheira de Frontend", "member", "#16a34a" ],
    [ :diego, "Diego Nunes", "Engenheiro de QA", "member", "#0891b2" ],
    [ :fernanda, "Fernanda Reis", "Engenheira Mobile", "member", "#9333ea" ],
    [ :helena, "Helena Moura", "Diretora de Produto (leitura)", "viewer", "#ca8a04" ]
  ].freeze

  # chave, nome, descrição, visão, cor, responsável, versões [nome, situação, dias a partir de hoje, notas]
  PRODUTOS = [
    [ :aurora, "Aurora", "Aplicativo de finanças pessoais que organiza cartões, metas e orçamento.",
      "Ajudar brasileiros comuns a **entender para onde vai o dinheiro** e a chegar nas suas metas, sem planilhas e sem jargão.\n\n- Público: 25 a 40 anos, primeira vez organizando as finanças\n- Promessa: abrir o app e saber, em 10 segundos, se o mês está sob controle\n- Meta de 12 meses: 200 mil usuários ativos por mês",
      "#7c3aed", :marina, [
        [ "v1.0", "released", -120, "Primeira versão pública: cadastro, cartões e faturas." ],
        [ "v1.1", "released", -42, "Metas de economia e gráfico de gastos por categoria." ],
        [ "v1.2", "in_progress", 18, "Notificações de vencimento e bloqueio por inatividade." ],
        [ "v2.0", "planned", 110, "Open Finance e compartilhamento de metas em família." ]
      ] ],
    [ :lume, "Lume", "Plataforma de analytics para pequenas lojas virtuais, com painéis prontos e alertas.",
      "Dar a lojistas pequenos o painel que só as grandes tinham: **vendas, estoque e campanhas** em uma tela, com alertas em linguagem simples.",
      "#0d9488", :rafael, [
        [ "v3.4", "released", -35, "Painel de vendas por canal." ],
        [ "v3.5", "in_progress", 24, "Alertas de estoque baixo e exportação de relatórios." ],
        [ "v4.0", "planned", 140, "Previsão de demanda." ]
      ] ]
  ].freeze

  PROJETOS = [
    {
      chave: "AUR", nome: "Aurora Mobile", produto: :aurora, lider: :fernanda, cor: "#7c3aed", status: "active", prioridade: "high",
      descricao: "App Aurora para Android e iOS: do cadastro ao acompanhamento de metas.", inicio: -75, fim: 45,
      equipe: %i[fernanda camila bruno diego rafael],
      marcos: [ [ "Beta fechado", -20, true ], [ "Lançamento v1.2", 18, false ], [ "Revisão de segurança", 32, false ] ],
      epicos: [ [ "Onboarding e cadastro", -75, -40 ], [ "Cartões e faturas", -55, 5 ], [ "Metas e orçamento", -40, 20 ], [ "Notificações e segurança", -12, 40 ] ],
      sprints: [
        { nome: "Sprint 1 · Fundações", versao: "v1.0", meta: "Cadastro e design system prontos", inicio: -70, fim: -57, taxa: 0.97, tarefas: [
          [ "story", "Cadastro com e-mail e senha", "high", 5, "auth,mobile", 0, :fernanda ],
          [ "task", "Validação de CPF no formulário", "medium", 2, "auth", 0, :fernanda ],
          [ "task", "Design system: botões e campos", "high", 5, "design", 0, :camila ],
          [ "task", "Tela de boas-vindas com carrossel", "medium", 3, "design,mobile", 0, :camila ],
          [ "bug", "Teclado cobre o campo de senha no Android", "high", 2, "android", 0, :fernanda ],
          [ "task", "Configurar pipeline de CI do app", "medium", 3, "infra", nil, :rafael ],
          [ "story", "Login com biometria", "high", 8, "auth,segurança", 3, :fernanda ]
        ] },
        { nome: "Sprint 2 · Cartões", versao: "v1.0", meta: "Listar cartões e mostrar a fatura", inicio: -56, fim: -43, taxa: 0.92, tarefas: [
          [ "story", "Listar cartões cadastrados", "high", 3, "mobile", 1, :fernanda ],
          [ "story", "Detalhe da fatura com categorias", "high", 8, "mobile", 1, :fernanda ],
          [ "task", "Endpoint de faturas paginado", "high", 5, "api", 1, :bruno ],
          [ "bug", "Valor da fatura arredondado errado", "urgent", 2, "api,financeiro", 1, :bruno ],
          [ "task", "Ícones de categorias", "low", 2, "design", 1, :camila ],
          [ "task", "Testes E2E do fluxo de cadastro", "medium", 3, "qa", 0, :diego ],
          [ "story", "Filtrar fatura por período", "medium", 3, "mobile", 1, :fernanda ]
        ] },
        { nome: "Sprint 3 · Metas", versao: "v1.1", meta: "Criar e acompanhar metas de economia", inicio: -42, fim: -29, taxa: 0.9, tarefas: [
          [ "story", "Criar meta de economia", "high", 5, "mobile", 2, :fernanda ],
          [ "story", "Acompanhar progresso da meta", "high", 5, "mobile", 2, :fernanda ],
          [ "task", "Gráfico de gastos por categoria", "medium", 8, "design,mobile", 2, :camila ],
          [ "task", "Cálculo de orçamento mensal", "high", 5, "api", 2, :bruno ],
          [ "bug", "Meta não atualiza após depósito", "high", 3, "mobile", 2, :fernanda ],
          [ "task", "Revisão de acessibilidade", "medium", 5, "design,a11y", nil, :camila ],
          [ "task", "Documentar a API de metas", "low", 2, "api,docs", 2, :bruno ]
        ] },
        { nome: "Sprint 4 · Beta fechado", versao: "v1.2", meta: "Estabilizar para o beta com 500 usuários", inicio: -28, fim: -15, taxa: 0.88, tarefas: [
          [ "task", "Monitoramento de erros em produção", "high", 3, "infra", nil, :rafael ],
          [ "bug", "Crash ao abrir o app sem internet", "urgent", 5, "mobile,estabilidade", 1, :fernanda ],
          [ "task", "Pesquisa de satisfação no beta", "medium", 3, "produto", nil, :camila ],
          [ "story", "Tela de ajuda e perguntas frequentes", "low", 3, "mobile", nil, :fernanda ],
          [ "task", "Ajustes de performance na lista de faturas", "medium", 5, "mobile,performance", 1, :fernanda ],
          [ "task", "Testes de regressão do beta", "high", 5, "qa", nil, :diego ]
        ] },
        { nome: "Sprint 5 · Notificações e segurança", versao: "v1.2", meta: "Avisos de vencimento e bloqueio por inatividade", inicio: -8, fim: 5, taxa: 0.8, tarefas: [
          [ "story", "Notificações push de vencimento", "high", 8, "mobile,push", 3, :fernanda ],
          [ "story", "Bloqueio automático por inatividade", "high", 5, "segurança,mobile", 3, :fernanda ],
          [ "task", "Preferências de notificação", "medium", 3, "mobile,push", 3, :fernanda ],
          [ "bug", "Crash ao abrir fatura sem conexão", "urgent", 5, "mobile,estabilidade", 1, :fernanda, nil, -2 ],
          [ "task", "Texto das notificações (UX writing)", "medium", 2, "design,push", 3, :camila ],
          [ "story", "Exportar fatura em PDF", "medium", 5, "api,mobile", 1, :bruno ],
          [ "task", "Endpoint de preferências de notificação", "high", 3, "api,push", 3, :bruno ],
          [ "task", "Cenários de teste para push", "medium", 3, "qa,push", 3, :diego ],
          [ "task", "Definir critérios de sucesso da v1.2", "medium", 2, "produto", nil, :marina ]
        ] },
        { nome: "Sprint 6 · Lançamento v1.2", versao: "v1.2", meta: "Fechar a v1.2 e publicar nas lojas", inicio: 8, fim: 21, taxa: 1, so_planejada: true, tarefas: [
          [ "task", "Revisão final de textos e traduções", "medium", 3, "design", nil, :camila ],
          [ "task", "Checklist de publicação nas lojas", "high", 2, "release", nil, :rafael ],
          [ "story", "Onboarding guiado da primeira meta", "medium", 3, "mobile", 0, :fernanda ]
        ] }
      ],
      backlog: [
        [ "story", "Integração com Open Finance", "high", 13, "api,open-finance", 1, nil ],
        [ "task", "Widget de saldo na tela inicial", "low", 5, "mobile", nil, nil ],
        [ "task", "Localização em espanhol", "low", 8, "i18n", nil, nil ],
        [ "bug", "Animação trava em aparelhos antigos", "medium", 3, "mobile,performance", nil, nil ],
        [ "story", "Compartilhar meta com familiar", "medium", 8, "mobile,social", 2, nil ],
        [ "task", "Modo escuro", "low", 5, "design,mobile", nil, nil ],
        [ "task", "Reduzir o tamanho do APK", "medium", 5, "android,performance", nil, nil ]
      ]
    },
    {
      chave: "API", nome: "Aurora API", produto: :aurora, lider: :bruno, cor: "#ea580c", status: "active", prioridade: "high",
      descricao: "Serviços de backend do Aurora: contas, cartões, faturas e metas.", inicio: -60, fim: 60,
      equipe: %i[bruno rafael diego],
      marcos: [ [ "API v2 estável", 25, false ], [ "Rate limiting em produção", -10, true ] ],
      epicos: [ [ "Autenticação e sessões", -60, -25 ], [ "Desempenho e escala", -30, 40 ] ],
      sprints: [
        { nome: "Sprint 1 · Contas", versao: "v1.0", meta: "Autenticação com tokens de curta duração", inicio: -56, fim: -43, taxa: 0.95, tarefas: [
          [ "story", "Autenticação com tokens JWT", "high", 8, "auth", 0, :bruno ],
          [ "task", "Renovação de token (refresh)", "high", 5, "auth", 0, :bruno ],
          [ "task", "Hash de senha com Argon2", "high", 3, "segurança", 0, :rafael ],
          [ "bug", "Token aceito após logout", "urgent", 3, "auth,segurança", 0, :bruno ],
          [ "task", "Testes de contrato da API", "medium", 5, "qa", nil, :diego ]
        ] },
        { nome: "Sprint 2 · Desempenho", versao: "v1.0", meta: "Reduzir o p95 das consultas de fatura", inicio: -42, fim: -29, taxa: 0.9, tarefas: [
          [ "task", "Índices nas tabelas de transações", "high", 3, "banco,performance", 1, :bruno ],
          [ "task", "Cache de categorias", "medium", 3, "performance", 1, :bruno ],
          [ "story", "Paginação por cursor", "medium", 5, "api", 1, :bruno ],
          [ "task", "Teste de carga com k6", "high", 5, "qa,performance", 1, :diego ],
          [ "bug", "Consulta lenta no extrato anual", "high", 3, "banco", 1, :rafael ]
        ] },
        { nome: "Sprint 3 · Limites e segurança", versao: "v1.1", meta: "Rate limiting e auditoria", inicio: -14, fim: -1, taxa: 0.82, tarefas: [
          [ "story", "Rate limiting por usuário e IP", "high", 8, "segurança", nil, :bruno ],
          [ "task", "Registro de auditoria de acessos", "medium", 5, "segurança", nil, :bruno ],
          [ "task", "Alertas de picos de erro 5xx", "medium", 3, "infra", 1, :rafael ],
          [ "task", "Revisar dependências vulneráveis", "high", 2, "segurança", nil, :rafael ]
        ] },
        { nome: "Sprint 4 · API v2", versao: "v1.2", meta: "Lançar a v2 da API com versionamento", inicio: -4, fim: 9, taxa: 0.8, tarefas: [
          [ "story", "Versionamento da API por cabeçalho", "high", 8, "api", 1, :bruno ],
          [ "task", "Guia de migração para a v2", "medium", 3, "docs", 1, :bruno ],
          [ "task", "Testes de compatibilidade v1 e v2", "high", 5, "qa", 1, :diego ],
          [ "bug", "Timeout no webhook de faturas", "high", 3, "api", nil, :rafael, nil, -1 ]
        ] }
      ],
      backlog: [
        [ "story", "Webhooks para parceiros", "medium", 8, "api", nil, nil ],
        [ "task", "Migrar logs para formato estruturado", "low", 3, "infra", nil, nil ],
        [ "bug", "Erro 500 com CPF contendo pontuação", "medium", 2, "api", nil, nil ]
      ]
    },
    {
      chave: "LUM", nome: "Lume Dashboard", produto: :lume, lider: :juliana, cor: "#0d9488", status: "active", prioridade: "medium",
      descricao: "Painel web do Lume: vendas, estoque e campanhas em uma tela.", inicio: -50, fim: 50,
      equipe: %i[juliana camila rafael diego marina],
      marcos: [ [ "Alertas de estoque", 20, false ], [ "Painel de campanhas", -15, true ] ],
      epicos: [ [ "Painel de vendas", -50, -10 ], [ "Alertas e relatórios", -20, 35 ] ],
      sprints: [
        { nome: "Sprint 1 · Painel de vendas", versao: "v3.4", meta: "Vendas por canal e período", inicio: -45, fim: -32, taxa: 0.95, tarefas: [
          [ "story", "Gráfico de vendas por canal", "high", 8, "gráficos", 0, :juliana ],
          [ "task", "Filtro de período personalizado", "medium", 3, "ui", 0, :juliana ],
          [ "task", "Layout responsivo do painel", "high", 5, "design,ui", 0, :camila ],
          [ "bug", "Total do mês ignora devoluções", "urgent", 3, "dados", 0, :rafael ],
          [ "task", "Testes visuais com Playwright", "medium", 3, "qa", nil, :diego ]
        ] },
        { nome: "Sprint 2 · Campanhas", versao: "v3.4", meta: "Comparar desempenho de campanhas", inicio: -31, fim: -18, taxa: 0.9, tarefas: [
          [ "story", "Tabela de campanhas com ordenação", "high", 5, "ui", 0, :juliana ],
          [ "task", "Indicador de retorno sobre anúncio", "high", 5, "dados", 0, :rafael ],
          [ "task", "Estados vazios e de erro", "low", 2, "design", 0, :camila ],
          [ "task", "Exportar tabela em CSV", "medium", 3, "ui", 1, :juliana ]
        ] },
        { nome: "Sprint 3 · Alertas", versao: "v3.5", meta: "Alertas de estoque baixo", inicio: -10, fim: 3, taxa: 0.6, tarefas: [
          [ "story", "Regras de alerta de estoque baixo", "high", 8, "alertas", 1, :juliana ],
          [ "task", "Tela de configuração de alertas", "high", 5, "ui,alertas", 1, :juliana ],
          [ "task", "Envio de alertas por e-mail", "medium", 5, "alertas,backend", 1, :rafael ],
          [ "bug", "Gráfico some em telas pequenas", "medium", 3, "ui", nil, :juliana ],
          [ "task", "Textos dos alertas", "low", 2, "design", 1, :camila, nil, -3 ],
          [ "task", "Validar limites de alerta com o cliente", "high", 2, "produto,alertas", 1, :marina ]
        ] }
      ],
      backlog: [
        [ "story", "Previsão de demanda", "high", 13, "dados,ia", nil, nil ],
        [ "task", "Tema escuro do painel", "low", 5, "ui", nil, nil ],
        [ "story", "Relatório mensal em PDF", "medium", 8, "relatórios", 1, nil ]
      ]
    },
    {
      chave: "POR", nome: "Portal do Cliente", produto: nil, lider: :rafael, cor: "#2563eb", status: "active", prioridade: "medium",
      descricao: "Portal interno para clientes acompanharem chamados e faturas.", inicio: -30, fim: 70,
      equipe: %i[rafael juliana diego],
      marcos: [ [ "Piloto com 5 clientes", 25, false ] ],
      epicos: [ [ "Acompanhamento de chamados", -30, 30 ] ],
      sprints: [
        { nome: "Sprint 1", meta: "Listagem e detalhe de chamados", inicio: -24, fim: -11, taxa: 0.85, tarefas: [
          [ "story", "Listagem de chamados com busca", "high", 5, "ui", 0, :juliana ],
          [ "task", "Tela de detalhe do chamado", "medium", 3, "ui", 0, :juliana ],
          [ "task", "Login com SSO da empresa", "high", 8, "auth", nil, :rafael ]
        ] },
        { nome: "Sprint 2", meta: "Respostas e anexos", inicio: -8, fim: 5, taxa: 0.5, tarefas: [
          [ "story", "Responder chamado pelo portal", "high", 5, "ui", 0, :juliana ],
          [ "task", "Upload de anexos com limite de tamanho", "medium", 5, "backend", 0, :rafael ],
          [ "bug", "Fuso horário errado nas datas", "medium", 2, "ui", nil, :juliana ]
        ] }
      ],
      backlog: [ [ "task", "Notificações por e-mail de nova resposta", "medium", 5, "backend", nil, nil ], [ "story", "Pesquisa de satisfação ao fechar chamado", "low", 3, "produto", nil, nil ] ]
    },
    {
      chave: "REB", nome: "Rebranding Aurora", produto: :aurora, lider: :camila, cor: "#db2777", status: "completed", prioridade: "medium",
      descricao: "Nova identidade visual do Aurora: logo, cores e tom de voz.", inicio: -150, fim: -90,
      equipe: %i[camila marina],
      marcos: [ [ "Identidade aprovada", -110, true ], [ "Manual de marca publicado", -92, true ] ],
      epicos: [ [ "Identidade visual", -150, -95 ] ],
      sprints: [
        { nome: "Sprint 1", meta: "Conceito e paleta", inicio: -145, fim: -132, taxa: 1, tarefas: [
          [ "task", "Pesquisa de referências visuais", "medium", 3, "design", 0, :camila ],
          [ "task", "Proposta de paleta de cores", "high", 3, "design", 0, :camila ],
          [ "task", "Teste de contraste das cores", "medium", 2, "a11y", 0, :camila ]
        ] },
        { nome: "Sprint 2", meta: "Logo e manual", inicio: -128, fim: -115, taxa: 1, tarefas: [
          [ "task", "Logo e variações", "high", 5, "design", 0, :camila ],
          [ "task", "Manual de marca", "high", 5, "design,docs", 0, :camila ],
          [ "task", "Guia de tom de voz", "medium", 3, "produto", 0, :marina ]
        ] }
      ],
      backlog: []
    }
  ].freeze

  PAGINAS = [
    [ "produto:aurora", "Visão e estratégia", "🎯", "# Visão e estratégia\n\nO Aurora existe para que **qualquer pessoa entenda o próprio dinheiro**.\n\n## Princípios\n\n1. Clareza antes de funcionalidade\n2. Zero jargão financeiro\n3. Dados do usuário são dele: privacidade por padrão\n\n## Indicadores\n\n| Indicador | Meta 12 meses |\n|---|---|\n| Usuários ativos/mês | 200 mil |\n| Metas criadas por usuário | 2 |\n| NPS | acima de 55 |\n", nil ],
    [ "produto:aurora", "Princípios de design", "🎨", "# Princípios de design\n\n- **Um número por vez.** A tela inicial mostra só o saldo do mês.\n- **Cor com significado.** Verde é seguro, âmbar é atenção, vermelho é urgente.\n- **Acessível desde o início:** contraste mínimo AA e suporte a leitores de tela.\n", "Visão e estratégia" ],
    [ "produto:aurora", "Decisões de arquitetura", "🧱", "# Decisões de arquitetura (ADR)\n\n## ADR-001: API REST versionada por cabeçalho\n\n**Contexto:** apps antigos continuam instalados por meses.\n\n**Decisão:** versionar por cabeçalho `Accept-Version`, mantendo duas versões vivas.\n\n**Consequência:** custo de manter dois contratos, mas nenhum app quebra no lançamento.\n", nil ],
    [ "produto:lume", "Métricas de sucesso", "📈", "# Métricas de sucesso\n\n- **Ativação:** lojista conecta a loja e vê o primeiro gráfico em até 10 minutos.\n- **Retenção:** 60% voltam na semana seguinte.\n- **Valor:** pelo menos um alerta útil por loja por mês.\n", nil ],
    [ "projeto:AUR", "Checklist de lançamento", "🚀", "# Checklist de lançamento\n\n- [ ] Versão e notas de release atualizadas\n- [ ] Testes de regressão concluídos\n- [ ] Revisão de acessibilidade\n- [ ] Capturas de tela e textos das lojas\n- [ ] Plano de reversão combinado\n\n> Nunca publique numa sexta-feira.\n", nil ],
    [ "projeto:AUR", "Guia de contribuição", "📘", "# Guia de contribuição\n\n## Fluxo\n\n1. Crie uma branch `tipo/AUR-123-descricao`\n2. Abra o PR com a chave da tarefa no título\n3. Exija uma revisão e o CI verde\n\n## Commits\n\nUse o imperativo: `Adiciona filtro por período`.\n", nil ],
    [ "projeto:AUR", "Runbook de incidentes", "🚨", "# Runbook de incidentes\n\n**Severidade 1** (app fora do ar): acione o plantão e abra o canal de incidente.\n\n```text\n1. Confirmar o impacto\n2. Comunicar no canal #incidentes\n3. Mitigar (reverter versão, se preciso)\n4. Escrever o post-mortem em até 48h\n```\n", nil ],
    [ "projeto:API", "Contrato da API v2", "📑", "# Contrato da API v2\n\nTodas as rotas usam `Accept-Version: 2`.\n\n## Erros\n\n```json\n{ \"error\": \"mensagem\", \"code\": \"INVALID_CPF\" }\n```\n", nil ]
  ].freeze

  # [tarefa, quem, texto, há quantos dias]
  COMENTARIOS = [
    [ "AUR-2", :camila, "Sugiro mostrar a máscara do CPF enquanto a pessoa digita. @fernanda consegue?", 70 ],
    [ "AUR-2", :fernanda, "Consigo! Já deixei no PR.", 69 ],
    [ "AUR-11", :rafael, "Isso é crítico: valor de fatura errado corrói a confiança. @bruno prioriza hoje?", 52 ],
    [ "AUR-11", :bruno, "Era arredondamento em float. Troquei para centavos inteiros e adicionei teste.", 51 ],
    [ "AUR-19", :diego, "Reproduzi em 3 aparelhos. Anexei os passos na descrição.", 36 ],
    [ "AUR-26", :rafael, "Vamos usar o Sentry com amostragem de 20% para controlar custo.", 25 ],
    [ "AUR-27", :marina, "Prioridade para o beta: este bug derrubou a nota na loja. @fernanda @diego", 22 ],
    [ "AUR-31", :fernanda, "Ainda investigando: só acontece com fatura de mais de 200 itens.", 6 ],
    [ "AUR-31", :rafael, "Podemos paginar a lista e reduzir a pressão de memória. Faz sentido?", 5 ],
    [ "AUR-33", :camila, "Rascunho dos textos no Figma. Quem revisa o tom de voz? @marina", 4 ],
    [ "API-4", :rafael, "Token válido depois do logout é falha de segurança séria. Corrigir antes de qualquer feature.", 50 ],
    [ "API-4", :bruno, "Corrigido com lista de revogação em cache. Testes de contrato cobrindo.", 49 ],
    [ "API-19", :bruno, "Estimativa alta porque precisamos manter v1 viva por 6 meses.", 5 ],
    [ "LUM-4", :rafael, "Devoluções precisam entrar com sinal negativo, senão o total fica inflado.", 40 ],
    [ "LUM-13", :juliana, "Falta decidir o limite padrão de estoque baixo. @marina pode confirmar com o cliente?", 6 ],
    [ "LUM-13", :marina, "Cliente pediu 10% do estoque médio. Vou registrar na documentação.", 5 ],
    [ "POR-4", :rafael, "SSO fechado com o time de TI do cliente. Falta só o ambiente de homologação.", 15 ]
  ].freeze

  def self.descricao(tipo, titulo)
    case tipo
    when "bug" then "**Como reproduzir**\n\n1. Abra o app\n2. Siga o fluxo descrito no título\n\n**Esperado:** o comportamento correto.\n**Atual:** #{titulo.downcase}.\n"
    when "story" then "Como usuário, quero **#{titulo.downcase}** para ter mais controle do meu dia a dia.\n\n**Critérios de aceite**\n\n- Funciona offline quando possível\n- Textos revisados pelo time de design\n- Cobertura de testes automatizados\n"
    else "Detalhar e executar: #{titulo.downcase}.\n"
    end
  end
end
