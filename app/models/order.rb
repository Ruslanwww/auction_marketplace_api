# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :integer          default(0), not null
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lot_id           :integer
#  user_id          :integer
#
# Indexes
#
#  index_orders_on_lot_id   (lot_id)
#  index_orders_on_user_id  (user_id)
#

class Order < ApplicationRecord
  belongs_to :user
  belongs_to :lot

  validates :arrival_location, :arrival_type, :status, presence: true
end
