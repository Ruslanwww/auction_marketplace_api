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

FactoryBot.define do
  factory :order do
    arrival_location { Faker::Address.full_address }
    arrival_type { %i[pickup royal_mail united_states_postal_service dhl_express].sample }
    association :lot, status: :closed
  end
end
