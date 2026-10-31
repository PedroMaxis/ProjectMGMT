class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.references :project, foreign_key: true
      t.references :product, foreign_key: true
      t.references :parent, foreign_key: { to_table: :pages }
      t.references :author, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :icon
      t.text :body
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
