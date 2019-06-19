FactoryBot.define do
  factory :lot do
    title { Faker::Food.fruits }
    current_price { Faker::Number.between(2.1, 10.5) }
    estimated_price { Faker::Number.between(10.5, 50.0) }
    lot_start_time { Faker::Date.forward(10) }
    lot_end_time { Faker::Date.between(11.days.from_now, 20.days.from_now) }
    user
  end
end
