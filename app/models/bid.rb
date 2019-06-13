# == Schema Information
#
# Table name: bids
#
#  id                :integer          not null, primary key
#  bid_creation_time :datetime
#  proposed_price    :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  lot_id            :integer
#  user_id           :integer
#
# Indexes
#
#  index_bids_on_lot_id   (lot_id)
#  index_bids_on_user_id  (user_id)
#

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :lot
end
