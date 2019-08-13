# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'factory_bot_rails'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

DatabaseCleaner.clean

quantity = 10

#User
FactoryBot.create_list(:user, quantity)
puts "Created #{quantity} users"

#Lot
FactoryBot.create_list(:lot, quantity, user: User.first, status: :in_process)
puts "Created #{quantity} lots"

#Bid
Lot.all.each do |lot|
  FactoryBot.create(:bid, lot: lot, user: User.last)
end
puts "Created #{quantity} bids"

#Order
Lot.all.each do |lot|
  lot.closed!
  FactoryBot.create(:order, lot: lot, bid: lot.bids.last)
end
puts "Created #{quantity} orders"
