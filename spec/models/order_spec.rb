require "rails_helper"

RSpec.describe Order, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:lot) }
  end
end
