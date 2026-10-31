# Evolui a tabela de projetos da primeira versão: ganha chave curta (WEB, API…), líder, produto e cor,
# e os valores de prioridade e status (em inglês) passam para os novos identificadores.
class EvolveProjects < ActiveRecord::Migration[8.0]
  PRIORIDADES = { "High" => "high", "Medium" => "medium", "Low" => "low" }.freeze
  STATUS = { "Not Started" => "planning", "In Progress" => "active", "Completed" => "completed" }.freeze

  def up
    add_column :projects, :key, :string
    add_column :projects, :color, :string, null: false, default: "#7c3aed"
    add_reference :projects, :lead, foreign_key: { to_table: :users }
    add_reference :projects, :product, foreign_key: true

    usados = []
    select_rows("SELECT id, name, priority, status FROM projects ORDER BY id").each do |id, nome, prioridade, status|
      chave = gerar_chave(nome.to_s, usados)
      usados << chave
      execute sanitize("UPDATE projects SET key = ?, priority = ?, status = ? WHERE id = ?", chave, PRIORIDADES.fetch(prioridade, "medium"), STATUS.fetch(status, "planning"), id)
    end

    change_column_null :projects, :key, false
    add_index :projects, :key, unique: true
    change_column_default :projects, :priority, from: nil, to: "medium"
    change_column_default :projects, :status, from: nil, to: "planning"
  end

  def down
    remove_index :projects, :key
    remove_reference :projects, :product, foreign_key: true
    remove_reference :projects, :lead, foreign_key: { to_table: :users }
    remove_column :projects, :color
    remove_column :projects, :key
  end

  private

  def gerar_chave(nome, usados)
    base = nome.unicode_normalize(:nfd).gsub(/[^A-Za-z ]/, "").split.map { |p| p[0] }.join.upcase[0, 4]
    base = nome.gsub(/[^A-Za-z]/, "").upcase[0, 3] if base.length < 2
    base = "PRJ" if base.length < 2
    chave = base
    n = 2
    while usados.include?(chave)
      chave = "#{base}#{n}"
      n += 1
    end
    chave
  end

  def sanitize(sql, *valores)
    ActiveRecord::Base.sanitize_sql_array([ sql, *valores ])
  end
end
