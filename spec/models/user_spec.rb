# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  allow_password_change  :boolean          default(FALSE)
#  birth_day              :date
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  firstname              :string
#  lastname               :string
#  phone                  :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :text
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_phone                 (phone) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#

require "rails_helper"

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:lots).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:bids).dependent(:destroy) }
  end

  describe "#firstname" do
    it { should validate_presence_of(:firstname) }
  end

  describe "#lastname" do
    it { should validate_presence_of(:lastname) }
  end

  describe "#email" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }

    it { should validate_presence_of(:email) }

    it "validates the uniqueness" do
      user.email = user2.email
      user.valid?
      expect(user.errors[:email]).to include "has already been taken"
    end

    it "validates the regexp" do
      user.email = "email.com"
      user.valid?
      expect(user.errors[:email]).to include "is not an email"
    end
  end

  describe "#phone" do
    let(:user) { create(:user) }

    it { should validate_presence_of(:phone) }

    it "unique required" do
      expect(user).to validate_uniqueness_of(:phone).case_insensitive
    end

    it "validates the regexp" do
      user.phone = "+1-541.-754-3010"
      user.valid?
      expect(user.errors[:phone]).to include "is not a phone"
    end
  end

  describe "#birth_day" do
    let(:user) { create(:user) }

    it { should validate_presence_of(:birth_day) }

    it "validates age must be > 21" do
      user.birth_day = 18.years.ago
      user.valid?
      expect(user.errors[:birth_day]).to include "You must be 21 years or older"
    end
  end

  describe "#password" do
    it { should validate_presence_of(:password) }

    it "validates the length in 6..128" do
      should validate_length_of(:password).is_at_least(6).is_at_most(128)
    end
  end

  it "should create a user" do
    expect { create :user }.to change { User.count }.by(1)
  end
end
