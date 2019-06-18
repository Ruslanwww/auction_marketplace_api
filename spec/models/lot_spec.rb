require "rails_helper"

RSpec.describe Lot, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:bids).dependent(:destroy) }
    it { should have_one(:order).dependent(:destroy) }
  end
end
