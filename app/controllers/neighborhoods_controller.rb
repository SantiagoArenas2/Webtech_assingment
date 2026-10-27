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

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)
    if @neighborhood.save
      redirect_to neighborhoods_path, notice: "Neighborhood created."
    else
      flash.now[:alert] = "Please correct the neighborhood form."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @neighborhood = Neighborhood.find(params[:id])
  end

  def update
    @neighborhood = Neighborhood.find(params[:id])
    if @neighborhood.update(neighborhood_params)
      redirect_to neighborhoods_path, notice: "Neighborhood updated."
    else
      flash.now[:alert] = "Please correct the neighborhood form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    neighborhood = Neighborhood.find(params[:id])
    if neighborhood.destroy
      redirect_to neighborhoods_path, notice: "Neighborhood deleted."
    else
      redirect_to neighborhoods_path, alert: neighborhood.errors.full_messages.to_sentence
    end
  end

  private

  def neighborhood_params
    params.require(:neighborhood).permit(:name)
  end
end
