class ListingsController < ApplicationController
  def index
    @rooms = Room.published.includes(:room_photos, property: :neighborhood)

    if params[:neighborhood_id].present?
      @rooms = @rooms.joins(:property).where(properties: { neighborhood_id: params[:neighborhood_id] })
    end
    @rooms = @rooms.under_rent(params[:max_rent]) if params[:max_rent].present?
    @rooms = @rooms.available_from_date(params[:available_from]) if params[:available_from].present?
  end

  def show
    @room = Room.includes(:room_photos, property: [:neighborhood, :amenities, :reviews]).find(params[:id])
  end
end
