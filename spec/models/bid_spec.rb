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

  context "validation for lot status" do
    let(:status) { :in_process }
    let(:bid) { build(:bid, lot: create(:lot, status: status)) }

    it "should valid if lot status :in_process" do
      expect(bid).to be_valid
    end

    context "when lot status :pending" do
      let(:status) { :pending }

      it "should lot status error" do
        bid.valid?
        expect(bid.errors[:lot]).to include "lot status must be in_process"
      end
    end

    context "when lot status :closed" do
      let(:status) { :closed }

      it "should lot status error" do
        bid.valid?
        expect(bid.errors[:lot]).to include "lot status must be in_process"
      end
    end
  end

  context "after create lot_current_price_update" do
    let(:bid) { create(:bid) }

    it "should update lot current_price" do
      expect(bid.lot.reload.current_price).to eq bid.proposed_price
    end
  end

  context "validation for the bid creator user" do
    let(:user_creator) { create(:user) }
    let(:user) { create(:user) }
    let(:lot) { create(:lot, status: :in_process, user: user_creator) }
    let(:bid_creator) { build(:bid, lot: lot, user: user_creator) }
    let(:bid) { build(:bid, lot: lot, user: user) }


    it "should error for lot creator" do
      bid_creator.valid?
      expect(bid_creator.errors[:user]).to include "can not be the creator of the lot"
    end

    it "should be valid for non lot creator" do
      expect(bid).to be_valid
    end
  end
end
