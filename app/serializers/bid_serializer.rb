class BidSerializer < ActiveModel::Serializer
  attributes :id, :proposed_price, :created_at
  attribute :customer, if: -> { instance_options[:customer_info] }
end
