class ChangeOrdersRef < ActiveRecord::Migration[5.2]
  def change
    remove_reference :orders, :user, foreign_key: true
    add_reference :orders, :bid, foreign_key: true
  end
end
