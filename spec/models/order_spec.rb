# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  arrival_location :text
#  arrival_type     :integer          not null
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bid_id           :integer
#  lot_id           :integer
#
# Indexes
#
#  index_orders_on_bid_id  (bid_id)
#  index_orders_on_lot_id  (lot_id)
#

require "rails_helper"

RSpec.describe Order, type: :model do
  describe "Associations" do
    it { should belong_to(:bid) }
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

  context "validation for lot status" do
    let(:status) { :closed }
    let(:lot) { create(:lot, status: :in_process) }
    let!(:bid) { create(:bid, lot: lot) }
    before(:each) do
      lot.update! status: status
    end
    let(:order) { build(:order, lot: lot, bid: bid) }

    it "should valid if lot status :in_process" do
      expect(order).to be_valid
    end

    context "when lot status :pending" do
      let(:status) { :pending }

      it "should lot status error" do
        order.valid?
        expect(order.errors[:lot]).to include "lot status must be closed"
      end
    end

    context "when lot status :closed" do
      let(:status) { :in_process }

      it "should lot status error" do
        order.valid?
        expect(order.errors[:lot]).to include "lot status must be closed"
      end
    end
  end

  context "validation for bid_belong_lot" do
    let(:lot) { create(:lot, status: :in_process) }
    let!(:bid) { create(:bid, lot: lot) }
    before(:each) do
      lot.closed!
    end
    let(:order) { build(:order, lot: lot, bid: create(:bid)) }

    it "should lot status error" do
      order.valid?
      expect(order.errors[:bid]).to include "bid must be winner and belong to the lot"
    end
  end

  context "after create callback" do
    let(:lot) { create :lot, status: :in_process }
    let!(:bid) { create :bid, lot: lot }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before(:each) do
      lot.closed!
    end

    subject { create :order, lot: lot, bid: bid }

    it "should email queues the job" do
      expect(UserMailer).to receive(:email_for_seller).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
      subject
    end
  end
end
