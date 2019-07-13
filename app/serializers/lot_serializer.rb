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

class LotSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :description, :current_price, :estimated_price,
            :image, :lot_start_time, :lot_end_time, :status
  attribute :my_lot, if: -> { instance_options[:check_my_lot] }
  has_many :bids, if: -> { instance_options[:show] }
end
