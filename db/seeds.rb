# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'factory_bot_rails'

#User
User.destroy_all

FactoryBot.create_list(:user, 10)

puts "Created #{User.count} users"