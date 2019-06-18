require "rails_helper"

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:lots).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:bids).dependent(:destroy) }
  end

  it "should create a user" do
    expect { create :user }.to change { User.count }.by(1)
  end
end
