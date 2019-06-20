FactoryBot.define do
  factory :bid do
    proposed_price { Faker::Number.between(10.5, 30.4) }
    user
    lot
  end
end
