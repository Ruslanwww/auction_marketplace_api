class BidsChannel < ApplicationCable::Channel
  def subscribed
    reject unless Lot.find_by(id: params[:lot_id])
    stream_from "bids_for_lot_#{params[:lot_id]}"
  end
end
