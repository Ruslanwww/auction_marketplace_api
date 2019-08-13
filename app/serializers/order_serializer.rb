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

class OrderSerializer < ActiveModel::Serializer
  attributes :id, :arrival_location, :arrival_type, :status, :created_at, :updated_at
end
