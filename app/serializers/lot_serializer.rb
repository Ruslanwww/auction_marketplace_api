class LotSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :current_price, :estimated_price,
             :image, :lot_start_time, :lot_end_time, :status
end
