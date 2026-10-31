class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.text :vision
      t.string :status, null: false, default: "active"
      t.string :color, null: false, default: "#7c3aed"
      t.references :owner, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :products, :slug, unique: true

    create_table :releases do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.string :status, null: false, default: "planned"
      t.date :target_date
      t.date :released_on
      t.text :notes
      t.timestamps
    end
  end
end
