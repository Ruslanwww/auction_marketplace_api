class LotSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :current_price, :estimated_price,
             :image, :lot_start_time, :lot_end_time, :status
  # belongs_to :user, if: -> { instance_options[:short] }
  # has_many :bids, if: -> { instance_options[:show] }
end
