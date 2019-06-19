# frozen_string_literal: true

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


class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable
  include DeviseTokenAuth::Concerns::User

  has_many :lots, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :phone, presence: true, uniqueness: true # , case_sensitive: false
  validates :email, uniqueness: true
  validates_format_of :phone, with: /\A(?:\+?\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- .]?\d{3}[- .]?\d{4}\z/,
                      message: "is not a phone"
  validates :birth_day, presence: true
  validate :validate_age

  private

  def validate_age
    if birth_day.present? && birth_day > 21.years.ago
      errors.add(:birth_day, 'You must be 21 years or older')
    end
  end
end
