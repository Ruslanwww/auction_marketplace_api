class LotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lot, only: [:show, :update, :destroy]
  before_action :owner, only: [:update, :destroy]

  def index
    @lots = Lot.where(status: :in_process).order(created_at: :desc).page(params[:page])
    render json: @lots, status: :ok
  end

  def my_lots
    @lots = Lot.where(user_id: current_user.id).order(created_at: :desc).page(params[:page])
    check_my_lot(@lots)
    render json: @lots, check_my_lot: true, status: :ok
  end

  def show
    render json: @lot, show: true
  end

  def create
    @lot = current_user.lots.new(lot_params)
    @lot.status = :pending

    if @lot.save
      render json: @lot, status: :created
    else
      render json: @lot.errors, status: :unprocessable_entity
    end
  end

  def update
    if @lot.update(lot_params)
      render json: @lot
    else
      render json: @lot.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @lot.destroy
  end

  private

    def check_my_lot(lots)
      lots.map do |lot|
        lot.my_lot = (lot.user_id == current_user.id)
      end
    end

    def owner
      @lot = current_user.lots.find_by(id: params[:id], status: :pending)
      render json: "You do not have permission to modify this lot", status: :unauthorized if @lot.nil?
    end

    def set_lot
      @lot = Lot.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Lot" }, status: :not_found
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
