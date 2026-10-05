class NeighborhoodsController < ApplicationController
  def index
    @neighborhoods = Neighborhood.order(:name)
  end

  def show
    @neighborhood = Neighborhood.find(params[:id])
    @rooms = Room.published
                 .joins(:property)
                 .where(properties: { neighborhood_id: @neighborhood.id })
                 .includes(:room_photos, property: :neighborhood)
  end
end
