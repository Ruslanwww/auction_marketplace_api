# == Schema Information
#
# Table name: bids
#
#  id             :integer          not null, primary key
#  proposed_price :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lot_id         :integer
#  user_id        :integer
#
# Indexes
#
#  index_bids_on_lot_id   (lot_id)
#  index_bids_on_user_id  (user_id)
#

require "rails_helper"

RSpec.describe Bid, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:lot) }
  end

  describe "#proposed_price" do
    let(:bid) { create(:bid) }

    it { should validate_presence_of(:proposed_price) }

    it "validates the greater than 0" do
      bid.proposed_price = -1.1
      bid.valid?
      expect(bid.errors[:proposed_price]).to include "must be greater than 0.0"
    end

    it "validates the greater than current price" do
      bid.proposed_price = bid.lot.current_price - 1.5
      bid.valid?
      expect(bid.errors[:proposed_price]).to include "must be greater than current price"
    end
  end
end
