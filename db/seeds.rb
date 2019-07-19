# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'factory_bot_rails'

quantity = 10

#User
User.destroy_all

FactoryBot.create_list(:user, quantity)

puts "Created #{quantity} users"

#Lot
Lot.destroy_all

FactoryBot.create_list(:lot, quantity)

puts "Created #{quantity} lots"