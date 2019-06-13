# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :string
#  status           :string           default("pending")
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
end
