class CreateBids < ActiveRecord::Migration[5.2]
  def change
    create_table :bids do |t|
      t.references :user, foreign_key: true
      t.references :lot, foreign_key: true
      t.datetime :bid_creation_time
      t.decimal :proposed_price

      t.timestamps
    end
  end
end
