# == Schema Information
#
# Table name: bids
#
#  id             :integer          not null, primary key
#  proposed_price :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lot_id         :integer
#  user_id        :integer
#
# Indexes
#
#  index_bids_on_lot_id   (lot_id)
#  index_bids_on_user_id  (user_id)
#

class BidSerializer < ActiveModel::Serializer
  attributes :id, :proposed_price, :created_at, :customer

  def customer
    Digest::SHA1.hexdigest([object.user_id, object.lot_id].join)[0...10]
  end
end
