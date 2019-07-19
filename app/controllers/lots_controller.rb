class LotsController < ApplicationController
  expose :lot

  def index
    lots = Lot.in_process.order(created_at: :desc).page(params[:page])
    render json: lots, status: :ok
  end

  def my_lots
    lots = current_user.lots.order(created_at: :desc).page(params[:page])
    check_my_lot(lots)
    render json: lots, check_my_lot: true, status: :ok
  end

  def show
    render json: lot, show: true
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

    def check_my_lot(lots)
      lots.map do |lot|
        lot.my_lot = (lot.user_id == current_user.id)
      end
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
