class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.date :start_date
      t.date :due_date
      t.string :priority
      t.string :status

      t.timestamps
    end
  end
end
