class RemoveBidCreationTimeFromBids < ActiveRecord::Migration[5.2]
  def change
    remove_column :bids, :bid_creation_time, :datetime
  end
end
