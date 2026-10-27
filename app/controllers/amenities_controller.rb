class AmenitiesController < ApplicationController
  def index
    @amenities = Amenity.order(:name)
  end

  def new
    @amenity = Amenity.new
  end

  def create
    @amenity = Amenity.new(amenity_params)
    if @amenity.save
      redirect_to amenities_path, notice: "Amenity created."
    else
      flash.now[:alert] = "Please correct the amenity form."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @amenity = Amenity.find(params[:id])
  end

  def update
    @amenity = Amenity.find(params[:id])
    if @amenity.update(amenity_params)
      redirect_to amenities_path, notice: "Amenity updated."
    else
      flash.now[:alert] = "Please correct the amenity form."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    amenity = Amenity.find(params[:id])
    amenity.destroy!
    redirect_to amenities_path, notice: "Amenity deleted."
  rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::RecordNotDestroyed
    redirect_to amenities_path, alert: "Could not delete this amenity."
  end

  private

  def amenity_params
    params.require(:amenity).permit(:name)
  end
end
