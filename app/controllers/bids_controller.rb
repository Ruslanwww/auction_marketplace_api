class BidsController < ApplicationController
  expose :bid
  expose :lot

  def index
    bids = Bid.where(lot_id: params[:lot_id]).order(proposed_price: :desc)
    render json: bids, status: :ok
  end

  def create
    bid = lot.bids.new(bid_params.merge(user: current_user))
    authorize bid
    bid.save!
    BidBroadcastJob.perform_later bid.id
    render json: bid, status: :created
  end

  private
    def bid_params
      params.require(:bid).permit(:proposed_price)
    end
end
