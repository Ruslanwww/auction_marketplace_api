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

  attr_accessor :customer

  after_create :lot_current_price_update, :check_estimated_price_lot

  validates :proposed_price, presence: true
  validates_numericality_of :proposed_price, greater_than: 0.0
  validate :proposed_great_current, :lot_in_process, :can_not_be_creator

  private

    def proposed_great_current
      return if proposed_price.blank? || lot.nil?

      errors.add(:proposed_price, "must be greater than current price") if proposed_price <= lot.current_price
      end

    def lot_in_process
      return if lot.nil?

      errors.add(:lot, "lot status must be in_process") unless lot.in_process?
    end

    def lot_current_price_update
      lot.current_price = proposed_price
      lot.save!
    end

    def can_not_be_creator
      return if user.nil?

      errors.add(:user, "can not be the creator of the lot") if user == lot.user
    end

    def check_estimated_price_lot
      if proposed_price >= lot.estimated_price
        lot.close!
        Sidekiq::ScheduledSet.new.select { |job| job.display_args.first == lot.id }.map(&:delete)
      end
    end
end
