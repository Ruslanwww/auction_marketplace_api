class BidBroadcastJob < ApplicationJob
  queue_as :default

  def perform(id)
    bid = Bid.find(id)
    ActionCable.server.broadcast "bids_for_lot_#{bid.lot_id}", BidSerializer.new(bid).as_json
  end
end
