class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:neighborhood, :rooms)
  end

  def show
    @property = Property.includes(:neighborhood, :amenities, rooms: :room_photos, reviews: :author)
                         .find(params[:id])
  end
end
