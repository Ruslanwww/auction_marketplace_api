# == Schema Information
#
# Table name: lots
#
#  id              :integer          not null, primary key
#  current_price   :decimal(, )
#  description     :text
#  estimated_price :decimal(, )
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  status          :integer          default("pending"), not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_lots_on_user_id  (user_id)
#

class Lot < ApplicationRecord
  mount_uploader :image, ImageUploader

  belongs_to :user
  has_many :bids, dependent: :destroy
  has_one :order, dependent: :destroy
  attr_accessor :my_lot

  enum status: [:pending, :in_process, :closed]
  validates :title, :current_price, :estimated_price, :status, :lot_start_time, :lot_end_time, presence: true
  validates_numericality_of :current_price, :estimated_price, greater_than: 0.0
  validate :est_price_greater_current, :end_after_start, :start_after_current_time

  private

    def est_price_greater_current
      return if estimated_price.blank? || current_price.blank?

      if estimated_price < current_price
        errors.add(:estimated_price, "must be greater than current price")
      end
    end

    def start_after_current_time
      return if lot_start_time.blank?

      if lot_start_time <= DateTime.current
        errors.add(:lot_start_time, "must be after the current time")
      end
    end

    def end_after_start
      return if lot_end_time.blank? || lot_start_time.blank?

      if lot_end_time < lot_start_time
        errors.add(:lot_end_time, "must be after the start time")
      end
    end
end
