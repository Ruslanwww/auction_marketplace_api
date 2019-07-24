# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :integer          default(0), not null
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lot_id           :integer
#  user_id          :integer
#
# Indexes
#
#  index_orders_on_lot_id   (lot_id)
#  index_orders_on_user_id  (user_id)
#

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:lot) }
  end

  describe "#arrival_location" do
    it { should validate_presence_of(:arrival_location) }
  end

  describe "#arrival_type" do
    it { should validate_presence_of(:arrival_type) }

    it do
      should define_enum_for(:arrival_type).
        with_values(%i[pickup royal_mail united_states_postal_service dhl_express])
    end
  end

  describe "#status" do
    it { should validate_presence_of(:status) }

    it { should define_enum_for(:status).with_values(%i[pending sent delivered]) }
  end
end
