FactoryBot.define do
  factory :user do
    firstname { Faker::Name.first_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.unique.phone_number }
    password { "123456" }
  end
end
