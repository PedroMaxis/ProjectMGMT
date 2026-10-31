# Dados de DEMONSTRAÇÃO (empresa e pessoas fictícias). `bin/rails db:seed` é idempotente; `bin/rails db:reset` recomeça do zero.
#
# Em vez de inserir linhas prontas, o seed SIMULA semanas de trabalho: cria as tarefas, anda com o relógio dia a dia
# (travel_to) e move os cartões de coluna. Assim histórico, burndown e velocidade saem dos mesmos mecanismos do sistema real.
return if User.exists?

require "active_support/testing/time_helpers"
require_relative "seeds/dados"

class Simulacao
  include ActiveSupport::Testing::TimeHelpers

  def initialize
    @rng = Random.new(2026)
    @hoje = Date.current
  end

  def run
    # Sem transação única de propósito: o histórico de eventos nasce nos callbacks after_commit, que só enxergam a
    # última mudança de cada tarefa se tudo for confirmado de uma vez. Cada passo precisa confirmar sozinho, como no uso real.
    criar_usuarios
    criar_produtos
    Dados::PROJETOS.each { |dados| criar_projeto(dados) }
    criar_paginas
    comentar
    puts "Seed pronto: #{User.count} usuários, #{Product.count} produtos, #{Project.count} projetos, #{Issue.count} tarefas, #{Event.count} eventos."
    puts "Entre com qualquer e-mail abaixo e a senha prumo123 (ou use os botões de demonstração):"
    User.alphabetical.each { |u| puts "  #{u.email.ljust(28)} #{u.role.ljust(7)} #{u.name}" }
  end

  private

  # roda o bloco "naquele dia, naquela hora" (as datas de criação e o histórico saem certos)
  def em(dia, hora = 10, &bloco)
    travel_to(Time.zone.local(dia.year, dia.month, dia.day, hora, @rng.rand(55))) { bloco.call }
  end

  def user(chave) = @users.fetch(chave)

  def criar_usuarios
    @users = Dados::USUARIOS.to_h do |chave, nome, cargo, papel, cor|
      [ chave, User.create!(name: nome, email: "#{chave}@prumo.dev", password: "prumo123", role: papel, job_title: cargo, color: cor) ]
    end
  end

  def criar_produtos
    @products = Dados::PRODUTOS.to_h do |chave, nome, desc, visao, cor, dono, versoes|
      prod = Product.create!(name: nome, description: desc, vision: visao, color: cor, owner: user(dono))
      versoes.each do |nome_v, status, dias, notas|
        data = @hoje + dias
        prod.releases.create!(name: nome_v, status: status, target_date: data, released_on: (status == "released" ? data : nil), notes: notas)
      end
      [ chave, prod ]
    end
  end

  def criar_projeto(d)
    inicio = @hoje + d[:inicio]
    projeto = em(inicio) do
      Project.create!(name: d[:nome], key: d[:chave], description: d[:descricao], status: d[:status], priority: d[:prioridade],
                      start_date: inicio, due_date: @hoje + d[:fim], lead: user(d[:lider]), product: @products[d[:produto]], color: d[:cor])
    end
    d[:equipe].each { |u| projeto.memberships.create!(user: user(u), role: (u == d[:lider] ? "lead" : "member")) }
    projeto.milestones.create!(d[:marcos].map { |t, dias, feito| { title: t, due_date: @hoje + dias, completed_on: (feito ? @hoje + dias : nil) } })

    # épicos (com datas, para o cronograma)
    epicos = d[:epicos].map do |titulo, ini, fim|
      em(inicio) { projeto.issues.create!(kind: "epic", title: titulo, priority: "medium", reporter: user(d[:lider]), start_date: @hoje + ini, due_date: @hoje + fim, status: "doing") }
    end

    pendentes = []
    d[:sprints].each_with_index do |s, i|
      itens = (s[:tarefas] + pendentes.map { |x| x }).dup
      pendentes = []
      pendentes = rodar_sprint(projeto, d, s, itens, epicos, i)
    end
    # backlog: criado ao longo do projeto
    proxima = { aurora: "v2.0", lume: "v4.0" }[d[:produto]]
    d[:backlog].each do |tipo, titulo, prio, est, etiquetas, ep, quem|
      t = criar_tarefa(projeto, d, [ tipo, titulo, prio, est, etiquetas, ep, quem ], epicos, [ inicio, @hoje - 3 ].max)
      vincular_versao(projeto, [ t ], proxima)
    end
  end

  def criar_tarefa(projeto, d, spec, epicos, criada_em)
    tipo, titulo, prio, est, etiquetas, ep, quem, descricao, prazo = spec
    em(criada_em, 9) do
      projeto.issues.create!(kind: tipo, title: titulo, priority: prio, estimate: est, labels: etiquetas.to_s.split(","), due_date: prazo,
                             parent: (ep ? epicos[ep] : nil), assignee: (quem ? user(quem) : nil), reporter: user(d[:lider]), description: descricao || Dados.descricao(tipo, titulo))
    end
  end

  # Simula uma sprint inteira. Devolve as tarefas que ficaram pendentes (voltam ao backlog).
  def rodar_sprint(projeto, d, s, itens, epicos, indice)
    ini = @hoje + s[:inicio]
    fim = @hoje + s[:fim]
    sprint = em(ini - 3) { projeto.sprints.create!(name: s[:nome], goal: s[:meta], start_date: ini, end_date: fim) }
    tarefas = itens.map do |spec|
      if spec.is_a?(Issue)
        spec
      else
        # a maioria das tarefas da sprint tem prazo no fim dela (algumas já nascem com prazo próprio, no índice 8)
        spec = spec.dup
        spec[8] = (spec[8] ? @hoje + spec[8] : (@rng.rand < 0.6 ? fim : nil))
        criar_tarefa(projeto, d, spec, epicos, ini - 4 - @rng.rand(5))
      end
    end
    em(ini - 1, 16) { tarefas.each { |t| t.update!(sprint: sprint) } }
    vincular_versao(projeto, tarefas, s[:versao])
    return tarefas.reject(&:done?) if s[:so_planejada]

    em(ini, 9) { Current.user = user(d[:lider]); sprint.start! }
    ultimo_dia = [ fim, @hoje ].min
    # cada tarefa recebe um "roteiro" dentro dos dias úteis da sprint: começa, vai para revisão e termina (ou trava no meio)
    # os dias do roteiro vêm da sprint INTEIRA; só os que já passaram acontecem (numa sprint ativa, o resto ainda está por vir)
    uteis = (ini..fim).reject { |x| x.saturday? || x.sunday? }
    roteiro = tarefas.to_h do |t|
      pronta = @rng.rand < s[:taxa]
      dias = uteis.sample(3, random: @rng).sort
      dias = [ uteis.first, uteis.first, uteis.first ] if dias.size < 3
      [ t.id, { comeca: dias[0], revisa: (pronta || @rng.rand < 0.5 ? dias[1] : nil), termina: (pronta ? dias[2] : nil) } ]
    end
    (ini..ultimo_dia).each do |dia|
      next if dia.saturday? || dia.sunday?
      tarefas.each do |t|
        r = roteiro[t.id]
        novo = if r[:termina] == dia then "done" elsif r[:revisa] == dia then "review" elsif r[:comeca] == dia then "doing" end
        next unless novo
        em(dia, 10 + @rng.rand(7)) { Current.user = t.assignee || user(d[:lider]); t.reload.update!(status: novo) }
      end
      em(dia, 19) { sprint.reload.capture_snapshot!(dia) if sprint.active? }
    end
    return [] unless fim < @hoje

    pendentes = tarefas.map(&:reload).reject(&:done?)
    em(fim, 18) { Current.user = user(d[:lider]); sprint.reload.complete! }
    pendentes.each { |t| t.reload }
    pendentes
  ensure
    Current.user = nil
  end

  # liga as tarefas à versão do produto que elas entregam (sem gerar evento: é só cadastro)
  def vincular_versao(projeto, tarefas, nome)
    return unless nome && projeto.product
    versao = projeto.product.releases.find_by(name: nome)
    Issue.where(id: tarefas.map(&:id)).update_all(release_id: versao.id) if versao
  end

  def criar_paginas
    Dados::PAGINAS.each do |alvo, titulo, icone, corpo, pai|
      espaco = alvo.start_with?("produto:") ? @products[alvo.split(":").last.to_sym] : Project.find_by!(key: alvo.split(":").last)
      pai_pagina = pai ? espaco.pages.find_by(title: pai) : nil
      em(@hoje - 20 - @rng.rand(40)) { espaco.pages.create!(title: titulo, icon: icone, body: corpo, parent: pai_pagina, author: user(:marina)) }
    end
  end

  def comentar
    Dados::COMENTARIOS.each do |chave, quem, texto, dias|
      issue = Issue.find_by_key!(chave)
      em(@hoje - dias, 11 + @rng.rand(5)) { issue.comments.create!(user: user(quem), body: texto) }
    end
  end
end

Simulacao.new.run
