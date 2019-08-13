class OrdersController < ApplicationController
  expose :order, -> { Order.find_by!(lot_id: params[:lot_id]) }
  expose :lot

  def show
    authorize order
    render json: order, status: :ok
  end

  def create
    order = Order.new(order_params.merge(lot: lot, bid: lot.winner_bid))
    authorize order
    order.save!
    render json: order, status: :created
  end

  def update
    authorize order
    if order.pending? && order.lot.user == current_user
      order.send_lot
    elsif order.sent? && order.bid.user == current_user
      order.confirm_delivery
    else
      order.update!(order_params)
    end
    render json: order, status: :ok
  end

  private
    def order_params
      params.require(:order).permit(:arrival_location, :arrival_type)
    end
end
