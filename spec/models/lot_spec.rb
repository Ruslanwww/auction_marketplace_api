# == Schema Information
#
# Table name: lots
#
#  id              :integer          not null, primary key
#  current_price   :decimal(, )
#  description     :text
#  estimated_price :decimal(, )
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  status          :integer          default("pending"), not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#
# Indexes
#
#  index_lots_on_user_id  (user_id)
#

require "rails_helper"

RSpec.describe Lot, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:bids).dependent(:destroy) }
    it { should have_one(:order).dependent(:destroy) }
  end

  describe "#title" do
    it { should validate_presence_of(:title) }
  end

  describe "#current_price" do
    let(:lot) { create(:lot) }

    it { should validate_presence_of(:current_price) }

    it "validates the greater than 0" do
      lot.current_price = 0.0
      lot.valid?
      expect(lot.errors[:current_price]).to include "must be greater than 0.0"
    end
  end

  describe "#estimated_price" do
    let(:lot) { create(:lot) }

    it { should validate_presence_of(:estimated_price) }

    it "validates the greater than 0" do
      lot.estimated_price = -1.1
      lot.valid?
      expect(lot.errors[:estimated_price]).to include "must be greater than 0.0"
    end

    it "validates the greater than current price" do
      lot.estimated_price = lot.current_price - 1.1
      lot.valid?
      expect(lot.errors[:estimated_price]).to include "must be greater than current price"
    end
  end

  describe "#lot_start_time" do
    let(:lot) { create(:lot) }

    it { should validate_presence_of(:lot_start_time) }

    it "validates the greater than current time" do
      lot.lot_start_time = 2.days.ago
      lot.valid?
      expect(lot.errors[:lot_start_time]).to include "must be after the current time"
    end
  end

  describe "#lot_end_time" do
    let(:lot) { create(:lot) }

    it { should validate_presence_of(:lot_end_time) }

    it "validates the greater than start time" do
      lot.lot_end_time = lot.lot_start_time - 3.minutes
      lot.valid?
      expect(lot.errors[:lot_end_time]).to include "must be after the start time"
    end

    describe "#status" do
      it { should validate_presence_of(:status) }
    end
  end
end
