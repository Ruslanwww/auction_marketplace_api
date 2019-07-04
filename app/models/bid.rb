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

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :lot

  validates :proposed_price, presence: true
  validates_numericality_of :proposed_price, greater_than: 0.0
  validate :proposed_great_current

  private

    def proposed_great_current
      return if proposed_price.blank?

      if proposed_price <= lot.current_price
        errors.add(:proposed_price, "must be greater than current price")
      end
    end
end
