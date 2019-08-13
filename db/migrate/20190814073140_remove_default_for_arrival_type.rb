class RemoveDefaultForArrivalType < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:orders, :arrival_type, from: 0, to: nil)
  end
end
