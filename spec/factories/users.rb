FactoryBot.define do
  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.unique.cell_phone }
    birth_day { Faker::Date.birthday(21, 65) }
    password { "123456" }
  end
end
