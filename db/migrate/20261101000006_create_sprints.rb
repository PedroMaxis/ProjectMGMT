class CreateSprints < ActiveRecord::Migration[8.0]
  def change
    create_table :sprints do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :goal
      t.date :start_date
      t.date :end_date
      t.string :status, null: false, default: "planned"
      t.datetime :completed_at
      t.timestamps
    end

    # uma foto por dia dos pontos restantes: é daqui que sai o gráfico de burndown
    create_table :sprint_snapshots do |t|
      t.references :sprint, null: false, foreign_key: true
      t.date :day, null: false
      t.integer :remaining_points, null: false, default: 0
      t.integer :total_points, null: false, default: 0
    end
    add_index :sprint_snapshots, %i[sprint_id day], unique: true
  end
end
