class LotsController < ApplicationController
  before_action :authenticate_user!

  def index
    lots = Lot.where(status: :in_process).order(created_at: :desc).page(params[:page])
    render json: lots, status: :ok
  end

  def my_lots
    lots = current_user.lots.order(created_at: :desc).page(params[:page])
    check_my_lot(lots)
    render json: lots, check_my_lot: true, status: :ok
  end

  def show
    lot = set_lot
    render json: lot, show: true
  end

  def create
    lot = current_user.lots.new(lot_params)
    if lot.save
      render json: lot, status: :created
    else
      render json: lot.errors, status: :unprocessable_entity
    end
  end

  def update
    lot = set_lot
    authorize lot
    if lot.update(lot_params)
      render json: lot
    else
      render json: lot.errors, status: :unprocessable_entity
    end
  end

  def destroy
    lot = set_lot
    authorize lot
    lot.destroy
  end

  private

    def check_my_lot(lots)
      lots.map do |lot|
        lot.my_lot = (lot.user_id == current_user.id)
      end
    end

    def set_lot
      Lot.find(params[:id])
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
