require "test_helper"

# Garante que quem usa o banco da primeira versão (projetos em inglês, equipe como lista de nomes) não perde nada.
class MigracaoTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "migra projetos, marcos e equipe da primeira versão para o modelo novo" do
    db = ActiveRecord::ConnectionAdapters::SQLite3Adapter.new(adapter: "sqlite3", database: ":memory:")
    agora = "datetime('now')"
    db.execute("CREATE TABLE projects (id INTEGER PRIMARY KEY AUTOINCREMENT, name varchar, description text, start_date date, due_date date, priority varchar, status varchar, created_at datetime NOT NULL, updated_at datetime NOT NULL)")
    db.execute("CREATE TABLE team_members (id INTEGER PRIMARY KEY AUTOINCREMENT, name varchar, role varchar, project_id integer NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL)")
    db.execute("CREATE TABLE milestones (id INTEGER PRIMARY KEY AUTOINCREMENT, title varchar, description text, due_date date, project_id integer NOT NULL, created_at datetime NOT NULL, updated_at datetime NOT NULL)")
    db.execute("INSERT INTO projects (name, description, start_date, due_date, priority, status, created_at, updated_at) VALUES ('Website Redesign', 'x', '2024-11-01', '2025-03-01', 'High', 'In Progress', #{agora}, #{agora}), ('Mobile App', 'y', '2024-12-01', '2025-06-01', 'Low', 'Not Started', #{agora}, #{agora}), ('Web Reports', 'z', '2024-12-01', '2025-06-01', 'Medium', 'Completed', #{agora}, #{agora})")
    db.execute("INSERT INTO team_members (name, role, project_id, created_at, updated_at) VALUES ('Ana Souza', 'Designer', 1, #{agora}, #{agora}), ('João Lima', 'Dev', 1, #{agora}, #{agora}), ('ana souza', 'Designer', 2, #{agora}, #{agora})")
    db.execute("INSERT INTO milestones (title, description, due_date, project_id, created_at, updated_at) VALUES ('Protótipo', 'x', '2025-01-10', 1, #{agora}, #{agora})")

    ActiveRecord::Migration.verbose = false
    %w[20261101000001_create_users 20261101000002_create_products 20261101000003_evolve_projects 20261101000004_create_memberships].each do |arquivo|
      require Rails.root.join("db/migrate/#{arquivo}")
      arquivo.sub(/\A\d+_/, "").camelize.constantize.new.exec_migration(db, :up)
    end

    projetos = db.select_rows("SELECT key, name, priority, status FROM projects ORDER BY id")
    assert_equal [ [ "WR", "Website Redesign", "high", "active" ], [ "MA", "Mobile App", "low", "planning" ], [ "WR2", "Web Reports", "medium", "completed" ] ], projetos, "chaves geradas e valores convertidos"

    assert_equal [ [ "Ana Souza", "Designer" ], [ "João Lima", "Dev" ] ], db.select_rows("SELECT name, job_title FROM users ORDER BY id"), "a mesma pessoa vira um único usuário"
    assert_equal [ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ] ], db.select_rows("SELECT project_id, user_id FROM memberships ORDER BY id")
    assert_equal [ [ "Protótipo", 1 ] ], db.select_rows("SELECT title, project_id FROM milestones"), "os marcos continuam intactos"
    assert_not db.table_exists?(:team_members)
  ensure
    db&.disconnect!
  end
end
