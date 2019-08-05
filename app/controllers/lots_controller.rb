class LotsController < ApplicationController
  expose :lot

  def index
    lots = Lot.in_process.order(created_at: :desc).page(params[:page])
    render json: lots, status: :ok
  end

  def my_lots
    lots = filtered_lot.order(created_at: :desc).page(params[:page])
    check_my_lot(lots)
    render json: lots, check_my_lot: true, status: :ok
  end

  def show
    check_win(lot) if lot.closed? && lot.bids.present?
    render json: lot, check_my_win: lot.closed?, status: :ok
  end

  def create
    lot = current_user.lots.new(lot_params)
    lot.save!
    render json: lot, status: :created
  end

  def update
    authorize lot
    lot.update!(lot_params)
    render json: lot
  end

  def destroy
    authorize lot
    lot.destroy
  end

  private
    def filtered_lot
      if params[:filter] == "created"
        current_user.lots
      elsif  params[:filter] == "participation"
        participation_lot
      else
        participation_lot.or(Lot.where(user_id: current_user.lots.pluck(:user_id)))
      end
    end

    def participation_lot
      Lot.where(id: current_user.bids.pluck(:lot_id))
    end

    def check_my_lot(lots)
      lots.map do |lot|
        lot.my_lot = (lot.user_id == current_user.id)
      end
    end

    def check_win(lot)
      lot.my_win = lot.winner_bid.user == current_user
    end

    def lot_params
      params.require(:lot).permit(:title,
                                  :description,
                                  :image,
                                  :current_price,
                                  :estimated_price,
                                  :lot_start_time,
                                  :lot_end_time)
    end
end
