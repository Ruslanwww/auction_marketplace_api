class BidsController < ApplicationController
  expose :bid

  def index
    bids = Bid.where(lot_id: params[:lot_id]).order(proposed_price: :desc)
    customer_info(bids)
    render json: bids, customer_info: true, status: :ok
  end

  def create
    bid = current_user.bids.new(bid_params)
    bid.save!
    render json: bid, status: :created
  end

  def destroy
    authorize bid
    bid.destroy
  end

  private

    def bid_params
      params.require(:bid).permit(:proposed_price, :lot_id)
    end

    def customer_info(bids)
      bids.map.with_index do |bid, i|
        if bid.user == current_user
          bid.customer = "You"
        else
          bid.customer = "Customer #{i + 1}"
        end
      end
    end
end
