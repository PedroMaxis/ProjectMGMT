# A equipe deixa de ser uma lista de nomes soltos e passa a ser de usuários de verdade.
# Quem já estava cadastrado como "membro da equipe" vira usuário (com senha aleatória) e participante do projeto.
class CreateMemberships < ActiveRecord::Migration[8.0]
  def up
    create_table :memberships do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.timestamps
    end
    add_index :memberships, %i[project_id user_id], unique: true

    por_nome = {} # a mesma pessoa em vários projetos vira um único usuário
    select_rows("SELECT name, role, project_id FROM team_members ORDER BY id").each do |nome, funcao, projeto_id|
      nome = nome.to_s.strip.presence || "Membro"
      user_id = por_nome[nome.downcase] ||= begin
        base = nome.unicode_normalize(:nfd).gsub(/[^A-Za-z]/, "").downcase.presence || "membro"
        email = "#{base}@migrado.local"
        n = 1
        email = "#{base}#{n += 1}@migrado.local" while select_value(sanitize("SELECT 1 FROM users WHERE email = ?", email))
        execute sanitize("INSERT INTO users (name, email, password_digest, role, job_title, color, created_at, updated_at) VALUES (?, ?, ?, 'member', ?, '#7c3aed', datetime('now'), datetime('now'))",
                         nome, email, BCrypt::Password.create(SecureRandom.hex(8)), funcao)
        select_value("SELECT last_insert_rowid()")
      end
      execute sanitize("INSERT OR IGNORE INTO memberships (project_id, user_id, role, created_at, updated_at) VALUES (?, ?, 'member', datetime('now'), datetime('now'))", projeto_id, user_id)
    end

    drop_table :team_members
  end

  def down
    create_table :team_members do |t|
      t.string :name
      t.string :role
      t.references :project, null: false, foreign_key: true
      t.timestamps
    end
    drop_table :memberships
  end

  private

  def sanitize(sql, *valores)
    ActiveRecord::Base.sanitize_sql_array([ sql, *valores ])
  end
end
