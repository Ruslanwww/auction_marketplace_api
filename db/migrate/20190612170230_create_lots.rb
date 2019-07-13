class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.string :image
      t.text :description
      t.integer :status, default: 0, null: false
      t.decimal :current_price
      t.decimal :estimated_price
      t.datetime :lot_start_time
      t.datetime :lot_end_time

      t.timestamps
    end
  end
end
