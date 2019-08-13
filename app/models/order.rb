# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :integer          not null
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bid_id           :integer
#  lot_id           :integer
#
# Indexes
#
#  index_orders_on_bid_id  (bid_id)
#  index_orders_on_lot_id  (lot_id)
#

class Order < ApplicationRecord
  belongs_to :bid
  belongs_to :lot

  after_create :send_mail_to_seller

  enum arrival_type: [:pickup, :royal_mail, :united_states_postal_service, :dhl_express]
  enum status: [:pending, :sent, :delivered]
  validates :arrival_location, :arrival_type, :status, presence: true
  validate :lot_closed, :bid_belong_lot

  def send_lot
    sent!
    UserMailer.email_about_sending(self).deliver_later
  end

  def confirm_delivery
    delivered!
    UserMailer.email_about_delivery(self).deliver_later
  end

  private
    def send_mail_to_seller
      UserMailer.email_for_seller(self).deliver_later
    end

    def lot_closed
      return if lot.nil?

      errors.add(:lot, "lot status must be closed") unless lot.closed?
    end

    def bid_belong_lot
      return if lot.nil? || bid.nil?

      errors.add(:bid, "bid must be winner and belong to the lot") unless lot.winner_bid == bid
    end
end
