class CreateIssues < ActiveRecord::Migration[8.0]
  def change
    create_table :issues do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :kind, null: false, default: "task"
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "todo"
      t.string :priority, null: false, default: "medium"
      t.float :position, null: false, default: 0
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :reporter, foreign_key: { to_table: :users }
      t.integer :estimate
      t.date :start_date
      t.date :due_date
      t.references :sprint, foreign_key: true
      t.references :parent, foreign_key: { to_table: :issues }
      t.references :release, foreign_key: true
      t.text :labels # lista em JSON; o Rails grava lista vazia como NULL
      t.datetime :completed_at
      t.timestamps
    end
    add_index :issues, %i[project_id number], unique: true
    add_index :issues, %i[project_id status position]

    create_table :comments do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    create_table :events do |t|
      t.references :project, null: false, foreign_key: true
      t.references :issue, foreign_key: true
      t.references :user, foreign_key: true
      t.string :kind, null: false
      t.text :details, null: false, default: "{}"
      t.datetime :created_at, null: false
    end
    add_index :events, %i[project_id created_at]
  end
end
