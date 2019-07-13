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

FactoryBot.define do
  factory :lot do
    title { Faker::Food.fruits }
    current_price { Faker::Number.between(2.1, 10.5) }
    estimated_price { Faker::Number.between(30.5, 50.0) }
    lot_start_time { Faker::Date.forward(10) }
    lot_end_time { Faker::Date.between(11.days.from_now, 20.days.from_now) }
    user
  end
end
