class BidsController < ApplicationController
  expose :bid

  def index
    bids = Bid.where(lot_id: params[:lot_id]).order(proposed_price: :desc)
    render json: bids, customer_info: true, status: :ok
  end

  def create
    bid = current_user.bids.create!(bid_params)
    authorize bid
    render json: bid, status: :created
  end

  private
    def bid_params
      params.require(:bid).permit(:proposed_price, :lot_id)
    end
end
